require 'error/command_error'

##
# TODO: Doc
module Commands
  def perform_append(target_symbol, expression_stack)
    unless @symbol_table.has_symbol target_symbol
      raise CommandError, "Cannot append to #{target_symbol} as it doesn't exist"
    end

    val = @symbol_table.retrieve_symbol target_symbol
    val += resolve_expression_stack expression_stack

    @symbol_table.store_symbol target_symbol, val
  end

  def perform_list
    @symbol_table.symbols.each do |sym|
      puts sym
    end
  end

  def perform_exit
    close
  end

  def perform_print(expression_stack)
    expr = resolve_expression_stack expression_stack
    puts expr
  end

  def perform_printlength(expression_stack)
    expr = resolve_expression_stack expression_stack
    puts expr.length
  end

  def perform_printwords(expression_stack)
    expr = resolve_expression_stack expression_stack
    matches = expr.scan /(\w+)*/

    puts 'Expression provided following words:'
    matches.each do |m|
      puts m
    end
  end

  def perform_printwordcount(expression_stack)
    expr = resolve_expression_stack expression_stack
    matches = expr.scan /(\w+)*/

    puts "Expression provided n=#{matches.length} words:"
  end

  def perform_set(target_symbol, expression_stack)
    expr = resolve_expression_stack expression_stack
    @symbol_table.store_symbol target_symbol, expr
  end

  def perform_reverse(target_symbol)
    unless @symbol_table.has_symbol target_symbol
      raise CommandError, "Cannot append to #{target_symbol} as it doesn't exist"
    end

    val = @symbol_table.retrieve_symbol target_symbol

    matches = val.scan /(\w+)*/
    matches.reverse.join ' '
  end

  private

  def resolve_expression_stack(expression_stack)
    val = ''
    expression_stack.each do |expr_symbol|
      unless @symbol_table.has_symbol expr_symbol
        raise CommandError,
              "Cannot append to #{target_symbol} as #{expr_symbol} referenced inside the expression doesn't exist"
      end

      val += (@symbol_table.retrieve_symbol expr_symbol)
    end

    val
  end
end
