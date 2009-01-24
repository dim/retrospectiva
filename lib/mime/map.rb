module Mime
  module Map

    KNOWN_TYPES = {
      'application/pdf' =>        ['pdf'],
      'application/postscript' => ['ps'],
      'application/rtf' =>        ['rtf'],
      'application/x-troff' =>    ['nroff', 'roff', 'troff'],
    
      'image/x-icon' =>           ['ico'],
      'image/svg+xml' =>          ['svg'],
      'image/png' =>              ['png'],
      'image/jpeg' =>             ['jpeg', 'jpg'],
      'image/gif' =>              ['gif'],
    
      'model/vrml' =>             ['vrml', 'wrl'],
    
      'text/css' =>               ['css'],
      'text/csv' =>               ['csv'],
      'text/html' =>              ['html', 'htm', 'xhtml'],
      'text/plain' =>             ['txt', 'TXT', 'text', 'README', 'INSTALL', 'LICENSE', 'GPL', 'GPL2', 'MIT', 'MIT-LICENSE',
                                    'AUTHORS', 'COPYING', 'ChangeLog', 'RELEASE', 'ini'],
      'text/xml' =>               ['xml'],
      'text/xsl' =>               ['xsl'],
      'text/x-flash' =>           ['as', 'mx'],
      'text/x-cgi' =>             ['cgi', 'fcgi'],
      'text/x-csrc' =>            ['c', 'xs'],
      'text/x-chdr' =>            ['h'],
      'text/x-c++src' =>          ['cc', 'CC', 'cpp', 'cxx', 'C'],
      'text/x-c++hdr' =>          ['hh', 'HH', 'hpp', 'hxx', 'H'],
      'text/x-csharp' =>          ['cs', 'csharp'],
      'text/x-diff' =>            ['diff', 'patch'],
      'text/x-eiffel' =>          ['e'],
      'text/x-elisp' =>           ['el'],
      'text/x-fortran' =>         ['f', 'for', 'f90', 'f95', 'f2k'],
      'text/x-haskell' =>         ['hs'],
      'text/x-javascript' =>      ['js'],
      'text/x-jsp' =>             ['jsp'],
      'text/x-log' =>             ['log'],
      'text/x-objc' =>            ['m', 'mm'],
      'text/x-makefile' =>        ['make', 'mk',
                                    'Makefile', 'makefile', 'GNUMakefile'],
      'text/x-pascal' =>          ['pas'],
      'text/x-perl' =>            ['pl', 'pm', 'PL', 'perl'],
      'text/x-php' =>             ['php', 'php3', 'php4', 'php5', 'inc'],
      'text/x-python' =>          ['py', 'python'],
      'text/x-pyrex' =>           ['pyx'],
      'text/x-ruby' =>            ['rb', 'ruby'],
      'text/x-script+shell' =>    ['sh', 'csh', 'bsh', 'bash', 'nsi', 'nsh'],
      'text/x-script+win' =>      ['bat', 'cmd', 'nt'],
      'text/x-scheme' =>          ['scm'],
      'text/x-html+template' =>   ['tmpl', 'rhtml', 'phtml'],
      'text/x-rails+template' =>  ['erb', 'builder'],
      'text/x-rakefile' =>        ['rake', 'Rakefile'],
      'text/x-capistrano' =>      ['Capfile'],
      'text/x-textile' =>         ['txtl', 'textile'],
      'text/x-vba' =>             ['vb', 'vba', 'vbs', 'bas'],
      'text/x-verilog' =>         ['v', 'verilog'],
      'text/x-vhdl' =>            ['vhd'],
      'text/x-yaml' =>            ['yaml', 'yml'],
    }.merge(
      ['ada', 'asm', 'asp', 'awk', 'idl', 'inf', 
      'java', 'ksh', 'lua', 'm4', 'mail', 'nfo', 'psp', 
      'rfc', 'rst', 'sql', 'tcl', 'tex', 'zsh'].inject({}) do |result,i|
        result["text/x-#{i}"] = [i]
        result
      end
    )

    TYPE_MAP = KNOWN_TYPES.inject({}) do |result, (k,v)|
      v.each do |ext|
        result[ext.downcase] = k
      end 
      result        
    end

    def self.mime_type(file_name)
      type = File.extname(file_name).gsub(%r{^\.}, '')
      type = file_name if type.blank?
      type && TYPE_MAP[type.downcase] ? TYPE_MAP[type.downcase] : nil
    end
    
    def self.unknown
      'application/octet-stream'    
    end
    
  end
end