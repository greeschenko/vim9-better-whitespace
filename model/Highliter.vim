vim9script

export class WhitespaceHighliter
    static const WHITESPACE_CHARS = '\u0020\u00a0\u1680\u180e\u2000-\u200b\u202f\u205f\u3000\ufeff'
    var ctermcolor: string = "red"
    var guicolor: string = "#FF0000"
    var eol_whitespace_pattern: string = '[\u0009' .. WHITESPACE_CHARS .. ']\+$'

    def new()
    enddef

    def Start(config: dict<any>)
        if has_key(config, "ctermcolor")
            this.ctermcolor = config.ctermcolor
        endif

        if has_key(config, "guicolor")
            this.guicolor = config.guicolor
        endif

        autocmd! FileType,WinEnter,BufWinEnter,CursorMoved * g:WhitespaceHighliter.HighlightEOLWhitespace()
        autocmd! ColorScheme * g:WhitespaceHighliter.WhitespaceInit()
        autocmd! CursorMovedI,InsertEnter * g:WhitespaceHighliter.HighlightEOLWhitespaceExceptCurrentLine()

        command! RemoveWhitespaces g:WhitespaceHighliter.RemoveWhitespaces() 
    enddef

    # Ensure the 'ExtraWhitespace' highlight group has been defined
    def WhitespaceInit()
        # Check if the user has already defined highlighting for this group
        if hlexists('ExtraWhitespace') == 0 || empty(synIDattr(synIDtrans(hlID('ExtraWhitespace')), 'bg'))
            execute 'highlight ExtraWhitespace ctermbg=' .. this.ctermcolor .. ' guibg=' .. this.guicolor
        endif
    enddef

    def HighlightEOLWhitespaceExceptCurrentLine()
        this.ClearHighlighting()
        exe 'syn match ExtraWhitespace excludenl "\%<' 
        .. line('.') 
        ..  'l' 
        .. this.eol_whitespace_pattern 
        ..  '\|\%>' 
        .. line('.') 
        ..  'l' 
        .. this.eol_whitespace_pattern 
        .. '"'
    enddef

    def HighlightEOLWhitespace()
        this.ClearHighlighting()
        execute 'syn match ExtraWhitespace excludenl "' .. this.eol_whitespace_pattern .. '"'
    enddef

    def RemoveWhitespaces()
        # Save the current search and cursor position
        var l = line('.')
        var c = col('.')

        silent execute ':%s/' .. this.eol_whitespace_pattern .. '//e'

        cursor(l, c)
    enddef

    # Remove Whitespace matching
    def ClearHighlighting()
        if hlexists('ExtraWhitespace') != 0
            syn clear ExtraWhitespace
        endif
    enddef
endclass
