class Card
  def initialize(**kwargs)
    kwargs.each do |field, value|
      instance_variable_set(method_to_ivar(field), value)
    end
  end

  def id
    "#{card_back_type.first}#{duel_type}"
  end

  def method_missing(method, *args)
    ivar = method_to_ivar(method)

    super unless instance_variable_defined?(ivar)

    if method.to_s[-1] == '='
      instance_variable_set(ivar, args.first)
    else
      instance_variable_get(ivar)
    end
  end

  def to_h
    instance_variables.to_h do |ivar|
      [ivar_to_method(ivar), instance_variable_get(ivar)]
    end
  end

  private

  def method_to_ivar(method)
    "@#{method.to_s.gsub('=', '')}".to_sym
  end

  def ivar_to_method(ivar)
    ivar.to_s[1..-1].to_sym
  end
end