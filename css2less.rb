
module Css2Less
  
  require 'enumerator'
  
  class Converter
    
    def initialize(css)
      @css = css
      @tree = {}
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
    
    def generate
      @css.split("\n").map { |l| l.strip }.join.gsub(/\/\*+[^\*]*\*+\//, '').split(/[\{\}]/).each_slice(2) do |style|
	rules = style[0].strip
	if rules.include?(',') # leave multiple rules alone
	  add_rule(@tree, [rules], style[1])
	else
	  add_rule(@tree, rules.split(/\s+/), style[1])
	end
      end
    end
    
    def print(tree=nil, indent=0)
      if tree.nil?
	tree = @tree
      end
      tree.each do |element, children|
	puts ' ' * indent + element + " {\n"
	style = children.delete(:style)
	if style
	  puts style.split(';').map { |s| s.strip }.reject { |s| s.empty? }.map { |s| ' ' * (indent+2) + s + ';' }.join("\n")
	end
	print(children, indent + 2)
	puts ' ' * indent + "}\n"
      end
    end
    
  end
  
end
