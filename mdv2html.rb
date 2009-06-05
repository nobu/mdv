#!/usr/bin/env ruby
# vim: fileencoding=utf-8 foldmethod=marker
require 'rubygems'
require 'markdown' # peg-markdown

def mdv2html(text)
  text = text.lines.to_a[1..-1].join # Just ignore the first line
  body = Markdown.new(text).to_html
  body.gsub!(%r!<code>\|(.*?)\|</code>!, '<kbd>\1</kbd>')
  body.gsub!(%r!^<p>Author: (.*?)</p>$!, '<p><author>\1</author></p>') # FIXME: It should apply ONLY for the last line
  body
end

def headerline2hash(line)
  m = line.match(/^# Hack #(\d+): (.*?) \| (.*?) (.*?)$/)
  {
    :hacknum => m[1].to_i,
    :title => m[2],
    :level => m[3],
    :date => Date.parse(m[4])
  }
end

fixture =
<<EOF # {{{
# Hack #22: Ultra Super Great Vim Plugin | lv2 2009-06-06

## PROBLEM
blah blah blah

## SOLUTION
use [blogger.vim](http://www.vim.org/scripts/script.php?script_id=2638)
with

the key mapping `|j|`.

## DISCUSSION
blah blah blah

    nnoremap j :<C-u>1000sl<Cr>
    nnoremap k :<C-u>1000sl<Cr>

blah blah blah. hara y y hara y?

Author: ujihisa
EOF
# }}}

case $0
when __FILE__
  puts mdv2html(fixture)
when /spec$/
  describe 'mdv2html' do
    it 'encodes mdv text to html text' do
      html =
      <<-EOF.gsub(/^\s+\|/, '').chomp # {{{
      |<h2>PROBLEM</h2>
      |
      |<p>blah blah blah</p>
      |
      |<h2>SOLUTION</h2>
      |
      |<p>use <a href="http://www.vim.org/scripts/script.php?script_id=2638">blogger.vim</a>
      |with</p>
      |
      |<p>the key mapping <kbd>j</kbd>.</p>
      |
      |<h2>DISCUSSION</h2>
      |
      |<p>blah blah blah</p>
      |
      |<pre><code>nnoremap j :&lt;C-u&gt;1000sl&lt;Cr&gt;
      |nnoremap k :&lt;C-u&gt;1000sl&lt;Cr&gt;
      |</code></pre>
      |
      |<p>blah blah blah. hara y y hara y?</p>
      |
      |<p><author>ujihisa</author></p>
      EOF
      # }}}
      mdv2html(fixture).should be_instance_of(String)
      mdv2html(fixture).should == html
    end
  end

  describe 'headerline2hash' do
    it 'gets hash from a line of header' do
      hash = {
        :date => Date.parse('2009-06-06'),
        :level => "lv2",
        :hacknum => 22,
        :title => "Ultra Super Great Vim Plugin"
      }
      headerline2hash(fixture.lines.to_a.first).should == hash
    end
  end
end
