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

  it "should convert basic css colors into global variables" do
    css = <<EOF
#hello {
    color: blue;
}

#hello #buddy {
    background: red;
    color: #333;
}

p {
  color: rgb(1,1,1);
  border: 1px dotted #e4e9f0;
}
EOF
    less = <<EOF
@color0: blue;
@color1: red;
@color2: #333;
@color3: rgb(1,1,1);
@color4: #e4e9f0;

#hello {
    color: @color0;
    #buddy {
        background: @color1;
        color: @color2;
    }
}
p {
    color: @color3;
    border: 1px dotted @color4;
}
EOF
    converter = Css2Less::Converter.new(css, {:update_colors => true})
    converter.process_less
    converter.get_less.should eq(less)
  end

  it "should generate appropriate vendor mixins" do
    css = <<EOF
.thumbnail-kenburn img {
  left:10px;
  margin-left:-10px;
  position:relative;
   -webkit-transition: all 0.8s ease-in-out;
   -moz-transition: all 0.8s ease-in-out;
   -o-transition: all 0.8s ease-in-out;
   -ms-transition: all 0.8s ease-in-out;
   transition: all 0.8s ease-in-out;
}
.thumbnail-kenburn:hover img {
   -webkit-transform: scale(1.2) rotate(2deg);
   -moz-transform: scale(1.2) rotate(2deg);
   -o-transform: scale(1.2) rotate(2deg);
   -ms-transform: scale(1.2) rotate(2deg);
   transform: scale(1.2) rotate(2deg);
}
 
/*Welcome Block*/
.service-block .span4 {
  padding:20px 30px;
  text-align:center;
  color: red;
  margin-bottom:20px;
  border-radius:2px;
    -webkit-transition:all 0.3s ease-in-out;
    -moz-transition:all 0.3s ease-in-out;
    -o-transition:all 0.3s ease-in-out;
    transition:all 0.3s ease-in-out;
}
EOF

    less = <<EOF
@color0: red;

.vp-transition(@p0; @p1; @p2) {
    -moz-transition: @p0 @p1 @p2;
    -o-transition: @p0 @p1 @p2;
    -ms-transition: @p0 @p1 @p2;
    -webkit-transition: @p0 @p1 @p2;
    transition: @p0 @p1 @p2;
}
.vp-transform(@p0; @p1) {
    -moz-transform: @p0 @p1;
    -o-transform: @p0 @p1;
    -ms-transform: @p0 @p1;
    -webkit-transform: @p0 @p1;
    transform: @p0 @p1;
}

.thumbnail-kenburn {
    img {
        left: 10px;
        margin-left: -10px;
        position: relative;
        .vp-transition(all;
        0.8s;
        ease-in-out);
    }
}
.thumbnail-kenburn:hover {
    img {
        .vp-transform(scale(1.2);
        rotate(2deg));
    }
}
.service-block {
    .span4 {
        padding: 20px 30px;
        text-align: center;
        color: @color0;
        margin-bottom: 20px;
        border-radius: 2px;
        .vp-transition(all;
        0.3s;
        ease-in-out);
    }
}
EOF

    converter = Css2Less::Converter.new(css, {:update_colors => true, :vendor_mixins => true})
    converter.process_less
    converter.get_less.should eq(less)

  end
end