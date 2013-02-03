require 'spec_helper'
require 'css2less'

describe Css2Less do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end

describe Css2Less::Converter do
  it "should convert basic css structure into less structure" do
    css = <<EOF
#hello {
    color: blue;
}

#hello #buddy {
    background: red;
}
EOF
    less = <<EOF
#hello {
    color: blue;
    #buddy {
        background: red;
    }
}
EOF
    converter = Css2Less::Converter.new(css)
    converter.process_less
    converter.get_less.should eq(less)
  end

  it "should correctly handle css child selectors" do
    css = <<EOF
body .navbar .nav > li > a {
  color: #333;
  font-weight: bold;
}
EOF
    less = <<EOF
body {
    .navbar {
        .nav {
            & > li {
                & > a {
                    color: #333;
                    font-weight: bold;
                }
            }
        }
    }
}
EOF
    converter = Css2Less::Converter.new(css)
    converter.process_less
    converter.get_less.should eq(less)
  end

  it "should correctly handle css @import rules" do
    css = <<EOF
@import "style1.css";
@import "style2.css";

@import "style3.css";

#hello {
    color: blue;
}

@import "style4.css";

#hello #buddy {
    background: red;
}
@import "style5.css";
EOF
    less = <<EOF
@import "style1.css";
@import "style2.css";
@import "style3.css";
@import "style4.css";
@import "style5.css";
#hello {
    color: blue;
    #buddy {
        background: red;
    }
}
EOF
    converter = Css2Less::Converter.new(css)
    converter.process_less
    converter.get_less.should eq(less)
  end
  
  it "should correctly handle @font-face rules" do
    css = <<EOF
@font-face {
  font-family: 'MyWebFont';
  src: url('webfont.eot'); /* IE9 Compat Modes */
  src: url('webfont.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
       url('webfont.woff') format('woff'), /* Modern Browsers */
       url('webfont.ttf')  format('truetype'), /* Safari, Android, iOS */
       url('webfont.svg#svgFontName') format('svg'); /* Legacy iOS */
}

#hello {
    color: blue;
}

#hello #buddy {
    background: red;
}
EOF
    less = <<EOF
@font-face {
    font-family: 'MyWebFont';
    src: url('webfont.eot');
    src: url('webfont.eot?#iefix') format('embedded-opentype'), url('webfont.woff') format('woff'), url('webfont.ttf')  format('truetype'), url('webfont.svg#svgFontName') format('svg');
}
#hello {
    color: blue;
    #buddy {
        background: red;
    }
}
EOF
    converter = Css2Less::Converter.new(css)
    converter.process_less
    converter.get_less.should eq(less)
  end
end