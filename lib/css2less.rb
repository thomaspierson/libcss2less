# Copyright 2012 Thomas Pierson <contact@thomaspierson.fr> ,
#		 Marcin Kulik <m@ku1ik.com>
#
# This file is part of Css2Less Library.
#
# Css2Less Library is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Css2Less Library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

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
      cleanup
      if @css.nil?
      return false
      end
      if @css.empty?
      return false
      end
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
        # leave multiple rules alone
        if rules.include?(',')
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
