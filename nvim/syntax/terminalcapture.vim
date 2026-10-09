if exists("b:current_syntax")
  finish
endif

syntax match TerminalCaptureCommand /^> .*/

highlight TerminalCaptureCommand guifg=#61afef gui=bold cterm=bold

let b:current_syntax = "terminalcapture"
