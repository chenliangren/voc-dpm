function model = lr_root_model(model)
% produce a model with left/right symmetric root filters
%
% model  object model with a single root filter

% symbol of the root filter
rootsym = model.rules{model.start}.rhs(1);

% create a fresh nonterminal for the new deformation rule
[model, N1] = model_add_nonterminal(model);

% add deformation rule with rigid deformation model for root filter
defparams = [1000 0 1000 0];
[model, rule] = model_add_def_rule(model, N1, rootsym, defparams);

% prevent learning or regularization penalty for root filter
model.blocks(rule.def.blocklabel).learn = 0;
model.blocks(rule.def.blocklabel).reg_mult = 0;

% replace the old rhs symbol with the deformation rule symbol
model.rules{model.start}.rhs(1) = N1;

% add a mirrored filter
[model, mrootsym] = model_mirror_terminal(model, rootsym);

% add mirrored deformation rule
[model, N2] = model_add_nonterminal(model);

model = model_add_def_rule(model, N2, mrootsym, defparams, ...
                           'def_blocklabel', rule.def.blocklabel, ...
                           'offset_w', model.blocks(rule.offset.blocklabel).w, ...
                           'offset_blocklabel', rule.offset.blocklabel, ...
                           'loc_w', model.blocks(rule.loc.blocklabel).w, ...
                           'loc_blocklabel', rule.loc.blocklabel, ...
                           'flip', true);

% add a new structure rule for the flipped deformation rule & filter
r = model.rules{model.start}(1);

model = model_add_struct_rule(model, model.start, N2, {[0 0 0]}, ...
                              'offset_w', model.blocks(r.offset.blocklabel).w, ...
                              'offset_blocklabel', r.offset.blocklabel, ...
                              'loc_w', model.blocks(r.loc.blocklabel).w, ...
                              'loc_blocklabel', r.loc.blocklabel, ...
                              'detection_window', r.detwindow, ...
                              'shift_detection_window', r.shiftwindow);
