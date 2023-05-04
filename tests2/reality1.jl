using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using Zygote
# using .EasyParse: @easyparse
# using .EasyParse
using EasyGrad

cat_dim3(arr) = cat(arr..., dims=3)
get_conf_loss_bc(args...) = get_conf_loss.(args...)
access_endi(i) = x -> x[.., i:i]
access_ele(i) = (x) -> x[i]
access_first(x) = x[1]
mse_fn_bc(args...) = mse_fn.(args...)
  
@easygrad model(
  prms::Union{Dict{Int64, M}, Vector{M}},
  data,#::Tuple{Vector{Array{Float32, BIT} where BIT}, Vector{Array{Float32, BOT} where BOT}, Vector{Array{Float32, B} where B}},
  graph::Real,
  train::Symbol = :OK,
) where M = begin
  X, Y, time_connect = data
  predict::Vector{Vector{M}} = [M[]]  # Core.box avoidance
  loss_state = 0.f0
  if size(time_connect, 1) > 0 && graph.is_rnn
    node_size = Zygote.@ignore (size(X[1][1])[1:end-1]..., 1)
    # @typeof prms
    # @code_warntype get_prm(prms, graph.states[1].var_index, state_init(;seed=graph.states[1].id), shape = node_size)
    init_state = [get_prm(prms, graph.states[i].var_index, Zygote.@ignore state_init(;seed=graph.states[i].id), shape = node_size)
                                  for i = 1:length(graph.states)]
    X_inp_s = Zygote.@ignore graph.prealloc
    state, pred = lax_scan(predict_fn, init_state, X_inp_s, (prms, graph))::Tuple{Vector{Vector{M}},Vector{Vector{M}}}

    predict = pred[1:end - STATE_OVERLAP]
    @assert STATE_OVERLAP == 0 || STATE_OVERLAP == 1 "Only overlap 1 is supported."
    # TODO calc prediction diff too?
    for si in 0:STATE_OVERLAP
      state_start = si === 0 ? init_state : state[si]
      loss_state += get_state_loss(state_start, state[end - si], time_connect[1]) # TODO maybe not only states?
    end
    if graph.loss_fn == "crypto"
      # loss_state *= 0f0
    end
    if graph.loss_fn == "diabtrend"
      # loss_state *= 3.f0
    end
    # loss_state *= 1f0
  else
    X_inp_sss = Zygote.@ignore (graph.prealloc[1][1],graph.prealloc[2][1],
                                  graph.prealloc[1][3],graph.prealloc[4][1],
                                  graph.prealloc[1][5],graph.prealloc[6][1])
    predict = predict_fn_no_state(X_inp_sss, (prms, graph))::Vector{Vector{M}}
  end

  if graph.loss_fn == "crypto"
    timesteps = size(predict, 1)
    pred_stack = [cat_dim3(predict[i])::M for i in 1:timesteps] # let pp = predict; timesteps = size(pp, 1); M[cat(pp[i]..., dims=3)::M for i in 1:timesteps] end  # SOME Serious Core box problem bcs of this line
    loss, loss_v = portfolio_loss(prms, graph, Y, pred_stack)
    # Zygote.@ignore graph.val_loss = loss_v
  elseif graph.loss_fn == "softmax"
    loss = mean(binary_crossentropy_fn(predict, Y[1][1])) ## TODO this is ANY type... because of stack inside...
  elseif graph.loss_fn == "diabtrend"
    timesteps = size(predict, 1)
    # @sizes Y[1]
    y_left, y_right = @Zygote.ignore get_interpolation_weights(Y[1])
    # @sizes y_left
    Y_true = map(access_endi(1), Y[1])
    Y_train = map(access_endi(2), Y[1])
    tmp = map(access_ele(1), predict)
    # @sizes predict
    dt_predict_raw = map(access_ele(1), predict)
    dt_predict = get_interpolated_values_raw(dt_predict_raw, y_left, y_right)
    loss::Float32 = mse_fn_bc(dt_predict, Y_true, Y_train) |> mean
    ups_down_loss = get_ups_downs_ups_loss(dt_predict_raw)
    if ups_down_loss > 0.3f0 * loss
      println("Warning. High up-down loss: $ups_down_loss")
    end
    loss += ups_down_loss
    loss += get_non_neg_loss(dt_predict_raw, 2.5f0) .* 10f0
    loss += get_non_neg_loss(init_state) .* 100f0 # TODO all state?
    if length(graph.out_idx) == 3
      conf_up = get_interpolated_values_raw(map(access_ele(2), predict), y_left, y_right) 
      conf_low = get_interpolated_values_raw(map(access_ele(3), predict), y_left, y_right)
      conf_loss = get_conf_loss_bc(conf_low, conf_up, Y_true, Y_train) |> mean
      loss += conf_loss * 0.25f0
    end
    # loss = mean_nonzero(loss, dims=1)[1]
    # loss += @gtime discriminator_loss(prms, prm_count(graph), Y[1], dt_predict)
    # disc_loss = discriminator_loss(prms, prm_count(graph), Y[1], dt_predict, train)
    # loss += disc_loss
  elseif graph.loss_fn == "mse"
    loss = loss_mse(predict, Y)
  else
    @assert false "Unrecognized loss fn name: $(graph.loss_fn)"
  end
  # @show loss
  loss += loss_state  # TODO finomhangolni
  # @show loss_state
  loss
end


#%%
using GraphPipe.GraphFunc: state_init, sumiter!
using GraphPipe.GraphPrmsFunc: get_prm, update_pro!
state_init_wrapper(node) = Zygote.@ignore state_init(;seed=node.id)
function pb_model_raw(prms::Union{Dict{Int64, M}, Vector{M}}, data, graph, train::Symbol = :OK) where M
  (X, Y, time_connect) = data
  predict::Vector{Vector{M}} = [M[]]
  loss_state = 0.0f0
  if size(time_connect, 1) > 0 && graph.is_rnn
      node_size = Zygote.@ignore(((size((X[1])[1]))[1:end - 1]..., 1))
      init_state = [begin
              (var"##tmp#575", var"##pb#576") = EasyGrad.Zygote.pullback(get_prm, prms, (graph.states[i]).var_index, begin
                          (var"##tmp#578", var"##pb#579") = EasyGrad.Zygote.pullback(state_init_wrapper, graph.states[i])
                          var"##tmp#578"
                      end, node_size)
              var"##tmp#575"
          end for i = 1:length(graph.states)]
      X_inp_s = Zygote.@ignore(graph.prealloc)
      (state, pred) = begin
                  (var"##tmp#572", var"##pb#573") = EasyGrad.Zygote.pullback(lax_scan, predict_fn, init_state, X_inp_s, (prms, graph))
                  var"##tmp#572"
              end::Tuple{Vector{Vector{M}}, Vector{Vector{M}}}
      begin
          s3_predict = predict
          predict = pred[1:end - STATE_OVERLAP]
      end
      @assert STATE_OVERLAP == 0 || STATE_OVERLAP == 1 "Only overlap 1 is supported."
      for si = 0:STATE_OVERLAP
          state_start = if si === 0
                  init_state
              else
                  state[si]
              end
          loss_state += begin
                  (var"##tmp#568", var"##pb#569") = EasyGrad.Zygote.pullback(get_state_loss, state_start, state[end - si], time_connect[1])
                  var"##tmp#568"
              end
      end
      if graph.loss_fn == "crypto"
      end
      if graph.loss_fn == "diabtrend"
      end
  else
      X_inp_sss = Zygote.@ignore(((graph.prealloc[1])[1], (graph.prealloc[2])[1], (graph.prealloc[1])[3], (graph.prealloc[4])[1], (graph.prealloc[1])[5], (graph.prealloc[6])[1]))
      begin
          s_predict = predict
          predict = predict_fn_no_state(X_inp_sss, (prms, graph))::Vector{Vector{M}}
      end
  end
  timesteps = begin
          (var"##tmp#565", var"##pb#566") = EasyGrad.Zygote.pullback(size, predict, 1)
          var"##tmp#565"
      end
  if graph.loss_fn == "crypto"
      pred_stack = [begin
                  (var"##tmp#482", var"##pb#483") = EasyGrad.Zygote.pullback(cat_dim3, predict[i])
                  var"##tmp#482"
              end::M for i = 1:timesteps]
      (loss, loss_v) = begin
              (var"##tmp#479", var"##pb#480") = EasyGrad.Zygote.pullback(portfolio_loss, prms, graph, Y, pred_stack)
              var"##tmp#479"
          end
      Zygote.@ignore graph.val_loss = loss_v
  elseif graph.loss_fn == "softmax"
      begin
          s3_loss = loss
          loss = mean(binary_crossentropy_fn(predict, (Y[1])[1]))
      end
  elseif graph.loss_fn == "diabtrend"
      (y_left, y_right) = Zygote.@ignore(get_interpolation_weights(Y[1]))
      Y_true = begin
              (var"##tmp#556", var"##pb#557") = EasyGrad.Zygote.pullback(map, begin
                          (var"##tmp#559", var"##pb#560") = EasyGrad.Zygote.pullback(access_endi, 1)
                          var"##tmp#559"
                      end, Y[1])
              var"##tmp#556"
          end
      Y_train = begin
              (var"##tmp#550", var"##pb#551") = EasyGrad.Zygote.pullback(map, begin
                          (var"##tmp#553", var"##pb#554") = EasyGrad.Zygote.pullback(access_endi, 2)
                          var"##tmp#553"
                      end, Y[1])
              var"##tmp#550"
          end
      tmp = begin
              (var"##tmp#544", var"##pb#545") = EasyGrad.Zygote.pullback(map, begin
                          (var"##tmp#547", var"##pb#548") = EasyGrad.Zygote.pullback(access_ele, 1)
                          var"##tmp#547"
                      end, predict)
              var"##tmp#544"
          end
      dt_predict_raw = begin
              (var"##tmp#538", var"##pb#539") = EasyGrad.Zygote.pullback(map, begin
                          (var"##tmp#541", var"##pb#542") = EasyGrad.Zygote.pullback(access_ele, 1)
                          var"##tmp#541"
                      end, predict)
              var"##tmp#538"
          end
      dt_predict = begin
              (var"##tmp#535", var"##pb#536") = EasyGrad.Zygote.pullback(get_interpolated_values_raw, dt_predict_raw, y_left, y_right)
              var"##tmp#535"
          end
      begin
          s_loss = loss
          loss::Float32 = mse_fn_bc(dt_predict, Y_true, Y_train) |> mean
      end
      ups_down_loss = begin
              (var"##tmp#525", var"##pb#526") = EasyGrad.Zygote.pullback(get_ups_downs_ups_loss, dt_predict_raw)
              var"##tmp#525"
          end
      if ups_down_loss > 0.3f0loss
          begin
              (var"##tmp#522", var"##pb#523") = EasyGrad.Zygote.pullback(println, "Warning. High up-down loss: $(ups_down_loss)")
              var"##tmp#522"
          end
      end
      loss += ups_down_loss
      loss += begin
                  (var"##tmp#519", var"##pb#520") = EasyGrad.Zygote.pullback(get_non_neg_loss, dt_predict_raw, 2.5f0)
                  var"##tmp#519"
              end .* 10.0f0
      loss += begin
                  (var"##tmp#516", var"##pb#517") = EasyGrad.Zygote.pullback(get_non_neg_loss, init_state)
                  var"##tmp#516"
              end .* 100.0f0
      if length(graph.out_idx) == 3
          conf_up = begin
                  (var"##tmp#507", var"##pb#508") = EasyGrad.Zygote.pullback(get_interpolated_values_raw, begin
                              (var"##tmp#510", var"##pb#511") = EasyGrad.Zygote.pullback(map, begin
                                          (var"##tmp#513", var"##pb#514") = EasyGrad.Zygote.pullback(access_ele, 2)
                                          var"##tmp#513"
                                      end, predict)
                              var"##tmp#510"
                          end, y_left, y_right)
                  var"##tmp#507"
              end
          conf_low = begin
                  (var"##tmp#498", var"##pb#499") = EasyGrad.Zygote.pullback(get_interpolated_values_raw, begin
                              (var"##tmp#501", var"##pb#502") = EasyGrad.Zygote.pullback(map, begin
                                          (var"##tmp#504", var"##pb#505") = EasyGrad.Zygote.pullback(access_ele, 3)
                                          var"##tmp#504"
                                      end, predict)
                              var"##tmp#501"
                          end, y_left, y_right)
                  var"##tmp#498"
              end
          conf_loss = begin
                  (var"##tmp#492", var"##pb#493") = EasyGrad.Zygote.pullback(mean, begin
                              (var"##tmp#495", var"##pb#496") = EasyGrad.Zygote.pullback(get_conf_loss_bc, conf_low, conf_up, Y_true, Y_train)
                              var"##tmp#495"
                          end)
                  var"##tmp#492"
              end
          loss += conf_loss * 0.25f0
      end
  elseif graph.loss_fn == "mse"
      loss = begin
              (var"##tmp#562", var"##pb#563") = EasyGrad.Zygote.pullback(loss_mse, predict, Y)
              var"##tmp#562"
          end
  else
      @assert false "Unrecognized loss fn name: $(graph.loss_fn)"
  end
  loss += loss_state
  (loss, EasyGrad.@refclosure((dd_y->begin
                  d_loss = dd_y
                  loss -= loss_state
                  d_loss_state = d_loss
                  begin
                      d_prms = (EasyGrad.e_zero)(prms)
                      d_graph = (EasyGrad.e_zero)(graph)
                      d_Y = (EasyGrad.e_zero)(Y)
                      d_pred_stack = (EasyGrad.e_zero)(pred_stack)
                      d_predict = (EasyGrad.e_zero)(predict)
                      d_conf_loss = (EasyGrad.e_zero)(conf_loss)
                      d_conf_low = (EasyGrad.e_zero)(conf_low)
                      d_conf_up = (EasyGrad.e_zero)(conf_up)
                      d_Y_true = (EasyGrad.e_zero)(Y_true)
                      d_Y_train = (EasyGrad.e_zero)(Y_train)
                      d_y_left = (EasyGrad.e_zero)(y_left)
                      d_y_right = (EasyGrad.e_zero)(y_right)
                      d_init_state = (EasyGrad.e_zero)(init_state)
                      d_dt_predict_raw = (EasyGrad.e_zero)(dt_predict_raw)
                      d_ups_down_loss = (EasyGrad.e_zero)(ups_down_loss)
                      d_dt_predict = (EasyGrad.e_zero)(dt_predict)
                  end
                  if graph.loss_fn == "crypto"
                      begin
                          var"##pb_tmp#481" = var"##pb#480"((d_loss, d_loss_v))
                          EasyGrad.@add! d_prms var"##pb_tmp#481"[1]
                          EasyGrad.@add! d_graph var"##pb_tmp#481"[2]
                          EasyGrad.@add! d_Y var"##pb_tmp#481"[3]
                          EasyGrad.@add! d_pred_stack var"##pb_tmp#481"[4]
                      end
                      for _i_i = 1:length(1:timesteps)
                          i = (1:timesteps)[_i_i]
                          begin
                              var"##pb_tmp#484" = var"##pb#483"(d_pred_stack[_i_i])
                              EasyGrad.@add! d_predict[i] var"##pb_tmp#484"[1]
                          end
                      end
                  elseif graph.loss_fn == "softmax"
                      loss = s3_loss
                      begin
                          var"##pb_tmp#488" = var"##pb#487"(d_loss)
                          begin
                              var"##pb_tmp#491" = var"##pb#490"(var"##pb_tmp#488"[1])
                              EasyGrad.@add! d_predict var"##pb_tmp#491"[1]
                              EasyGrad.@add! (d_Y[1])[1] var"##pb_tmp#491"[2]
                          end
                      end
                  elseif graph.loss_fn == "diabtrend"
                      if length(graph.out_idx) == 3
                          loss -= conf_loss * 0.25f0
                          EasyGrad.@add! d_conf_loss 0.25f0d_loss
                          begin
                              var"##pb_tmp#494" = var"##pb#493"(d_conf_loss)
                              begin
                                  var"##pb_tmp#497" = var"##pb#496"(var"##pb_tmp#494"[1])
                                  EasyGrad.@add! d_conf_low var"##pb_tmp#497"[1]
                                  EasyGrad.@add! d_conf_up var"##pb_tmp#497"[2]
                                  EasyGrad.@add! d_Y_true var"##pb_tmp#497"[3]
                                  EasyGrad.@add! d_Y_train var"##pb_tmp#497"[4]
                              end
                          end
                          begin
                              var"##pb_tmp#500" = var"##pb#499"(d_conf_low)
                              begin
                                  var"##pb_tmp#503" = var"##pb#502"(var"##pb_tmp#500"[1])
                                  EasyGrad.@add! d_predict var"##pb_tmp#503"[2]
                              end
                              EasyGrad.@add! d_y_left var"##pb_tmp#500"[2]
                              EasyGrad.@add! d_y_right var"##pb_tmp#500"[3]
                          end
                          begin
                              var"##pb_tmp#509" = var"##pb#508"(d_conf_up)
                              begin
                                  var"##pb_tmp#512" = var"##pb#511"(var"##pb_tmp#509"[1])
                                  EasyGrad.@add! d_predict var"##pb_tmp#512"[2]
                              end
                              EasyGrad.@add! d_y_left var"##pb_tmp#509"[2]
                              EasyGrad.@add! d_y_right var"##pb_tmp#509"[3]
                          end
                      end
                      loss -= get_non_neg_loss(init_state) .* 100.0f0
                      begin
                          var"##pb_tmp#518" = var"##pb#517"(100.0f0 .* d_loss)
                          EasyGrad.@add! d_init_state var"##pb_tmp#518"[1]
                      end
                      loss -= get_non_neg_loss(dt_predict_raw, 2.5f0) .* 10.0f0
                      begin
                          var"##pb_tmp#521" = var"##pb#520"(10.0f0 .* d_loss)
                          EasyGrad.@add! d_dt_predict_raw var"##pb_tmp#521"[1]
                      end
                      loss -= ups_down_loss
                      EasyGrad.@add! d_ups_down_loss d_loss
                      if ups_down_loss > 0.3f0loss
                          nothing
                      end
                      begin
                          var"##pb_tmp#527" = var"##pb#526"(d_ups_down_loss)
                          EasyGrad.@add! d_dt_predict_raw var"##pb_tmp#527"[1]
                      end
                      loss = s_loss
                      begin
                          var"##pb_tmp#531" = var"##pb#530"(d_loss)
                          begin
                              var"##pb_tmp#534" = var"##pb#533"(var"##pb_tmp#531"[1])
                              EasyGrad.@add! d_dt_predict var"##pb_tmp#534"[1]
                              EasyGrad.@add! d_Y_true var"##pb_tmp#534"[2]
                              EasyGrad.@add! d_Y_train var"##pb_tmp#534"[3]
                          end
                      end
                      begin
                          var"##pb_tmp#537" = var"##pb#536"(d_dt_predict)
                          EasyGrad.@add! d_dt_predict_raw var"##pb_tmp#537"[1]
                          EasyGrad.@add! d_y_left var"##pb_tmp#537"[2]
                          EasyGrad.@add! d_y_right var"##pb_tmp#537"[3]
                      end
                      begin
                          var"##pb_tmp#540" = var"##pb#539"(d_dt_predict_raw)
                          EasyGrad.@add! d_predict var"##pb_tmp#540"[2]
                      end
                      begin
                          var"##pb_tmp#546" = var"##pb#545"(d_tmp)
                          EasyGrad.@add! d_predict var"##pb_tmp#546"[2]
                      end
                      begin
                          var"##pb_tmp#552" = var"##pb#551"(d_Y_train)
                          EasyGrad.@add! d_Y[1] var"##pb_tmp#552"[2]
                      end
                      begin
                          var"##pb_tmp#558" = var"##pb#557"(d_Y_true)
                          EasyGrad.@add! d_Y[1] var"##pb_tmp#558"[2]
                      end
                  elseif graph.loss_fn == "mse"
                      var"##pb_tmp#564" = var"##pb#563"(d_loss)
                      EasyGrad.@add! d_predict var"##pb_tmp#564"[1]
                      EasyGrad.@add! d_Y var"##pb_tmp#564"[2]
                  else
                      nothing
                  end
                  begin
                      var"##pb_tmp#567" = var"##pb#566"(d_timesteps)
                      EasyGrad.@add! d_predict var"##pb_tmp#567"[1]
                  end
                  begin
                      d_state_start = (EasyGrad.e_zero)(state_start)
                      d_state = (EasyGrad.e_zero)(state)
                      d_time_connect = (EasyGrad.e_zero)(time_connect)
                      d_pred = (EasyGrad.e_zero)(pred)
                      d_predict_fn = (EasyGrad.e_zero)(predict_fn)
                      d_X_inp_s = (EasyGrad.e_zero)(X_inp_s)
                      d_node_size = (EasyGrad.e_zero)(node_size)
                      d_X_inp_sss = (EasyGrad.e_zero)(X_inp_sss)
                  end
                  if size(time_connect, 1) > 0 && graph.is_rnn
                      if graph.loss_fn == "diabtrend"
                          nothing
                      end
                      if graph.loss_fn == "crypto"
                          nothing
                      end
                      for si = reverse(0:STATE_OVERLAP)
                          loss_state -= get_state_loss(state_start, state[end - si], time_connect[1])
                          begin
                              var"##pb_tmp#570" = var"##pb#569"(d_loss_state)
                              EasyGrad.@add! d_state_start var"##pb_tmp#570"[1]
                              EasyGrad.@add! d_state[end - si] var"##pb_tmp#570"[2]
                              EasyGrad.@add! d_time_connect[1] var"##pb_tmp#570"[3]
                          end
                          if si === 0
                              EasyGrad.@add! d_init_state d_state_start
                          else
                              EasyGrad.@add! d_state[si] d_state_start
                          end
                      end
                      predict = s3_predict
                      EasyGrad.@add! d_pred[1:end - STATE_OVERLAP] d_predict
                      begin
                          var"##pb_tmp#574" = var"##pb#573"((d_state, d_pred))
                          EasyGrad.@add! d_predict_fn var"##pb_tmp#574"[1]
                          EasyGrad.@add! d_init_state var"##pb_tmp#574"[2]
                          EasyGrad.@add! d_X_inp_s var"##pb_tmp#574"[3]
                          EasyGrad.@add! d_prms (var"##pb_tmp#574"[4])[1]
                          EasyGrad.@add! d_graph (var"##pb_tmp#574"[4])[2]
                      end
                      for _i_i = 1:length(1:length(graph.states))
                          i = (1:length(graph.states))[_i_i]
                          begin
                              var"##pb_tmp#577" = var"##pb#576"(d_init_state[_i_i])
                              EasyGrad.@add! d_prms var"##pb_tmp#577"[1]
                              EasyGrad.@add! d_node_size var"##pb_tmp#577"[4]
                          end
                      end
                  else
                      predict = s_predict
                      begin
                          var"##pb_tmp#584" = var"##pb#583"(d_predict)
                          EasyGrad.@add! d_X_inp_sss var"##pb_tmp#584"[1]
                          EasyGrad.@add! d_prms (var"##pb_tmp#584"[2])[1]
                          EasyGrad.@add! d_graph (var"##pb_tmp#584"[2])[2]
                      end
                  end
                  d_data = (EasyGrad.e_zero)(data)
                  EasyGrad.@add! d_data (d_X, d_Y, d_time_connect)
                  (d_prms, d_data, d_graph)
              end)))
end

using JLD2
@load "EasyGrad.jl/tests2/model_input.jld2" prms data graph train
pb_model_raw(prms, data, graph, train)
