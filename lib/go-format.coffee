exec = require('child_process').exec

GoFormatStatusView = require('./go-format-status-view')

module.exports =
  view: null

  activate: (state) ->
    @view = new GoFormatStatusView(state.viewState)
    atom.project.eachEditor (editor) =>
      @attachEditor(editor)
    atom.subscribe atom.project, 'editor-created', (editor) =>
      @attachEditor(editor)

    atom.workspaceView.command 'go-format:format', =>
      editor = atom.workspace.getActiveEditor()
      if editor
        @format(editor)

  deactivate: ->
    @view.destroy()
    atom.unsubscribe(atom.project)

  serialize: ->
    viewState: @view.serialize()

  attachEditor: (editor) ->
    atom.subscribe editor.getBuffer(), 'reloaded saved', =>
      @format(editor)
    atom.subscribe editor.getBuffer(), 'destroyed', =>
      atom.unsubscribe(editor.getBuffer())

  format: (editor) ->
    if editor and editor.getPath()
      scope = editor.getCursorScopes()[0]
      if scope is 'source.go'
        exec 'go fmt ' + editor.getPath(), (err, stderr, stdout) =>
          if not err or err.code is 0
            text = 'Saved.'
          else
            text = '<span class="error">Format Error.</span>'
          @view.html(text).show()
