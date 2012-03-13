
module Css2Less
  
  require 'enumerator'
  
  class Converter
    
    def initialize(css=nil)
      if not css.nil?
	@css = css
      end
      @tree = {}
      @less = ''
    end
    
    def process_less
      if @css.nil?
	return false
      end
      cleanup
      generate_tree
      render_less
      return true
    end
    
    def get_less
      return @less
    end
    
    def set_css(css)
      @css = css
    end
    
    private
    
    def cleanup
      @tree = {}
      @less = ''
    end
    
    def add_rule(tree, selectors, style)
      return if style.nil? || style.empty?
      if selectors.empty?
	(tree[:style] ||= ';') << style
      else
	first, rest = selectors.first, selectors[1..-1]
	node = (tree[first] ||= {})
	add_rule(node, rest, style)
      end
    end
    
    def generate_tree
      @css.split("\n").map { |l| l.strip }.join.gsub(/\/\*+[^\*]*\*+\//, '').split(/[\{\}]/).each_slice(2) do |style|
	rules = style[0].strip
	if rules.include?(',') # leave multiple rules alone
	  add_rule(@tree, [rules], style[1])
	else
	  add_rule(@tree, rules.split(/\s+/), style[1])
	end
      end
    end
    
    def render_less(tree=nil, indent=0)
      if tree.nil?
	tree = @tree
      end
      tree.each do |element, children|
	@less = @less + ' ' * indent + element + " {\n"
	style = children.delete(:style)
	if style
	  @less = @less + style.split(';').map { |s| s.strip }.reject { |s| s.empty? }.map { |s| ' ' * (indent+4) + s + ";" }.join("\n") + "\n"
	end
	render_less(children, indent + 4)
	@less = @less + ' ' * indent + "}\n"
      end
    end
    
  end
  
end
