$(() => {
  const currentComponentId = window.DecidimAnonymousProposals.currentComponentId;
  if (!currentComponentId) {
    return;
  }

  const titleStoreId = `new_proposal:title:${currentComponentId}`;
  const bodyStoreId = `new_proposal:body:${currentComponentId}`;
  const bodyEditorStoreId = `new_proposal:body_editor:${currentComponentId}`;
  const $form = $("form.new_proposal");

  if (!$form.length) {
    window.localStorage.removeItem(titleStoreId);
    window.localStorage.removeItem(bodyStoreId);
    window.localStorage.removeItem(bodyEditorStoreId);
    return;
  } else {
    const $title = $form.find("#proposal_title");
    const $body = $form.find("#proposal_body");
    const editorContainer = document.querySelector(".editor-container");
    const editor = editorContainer ? Quill.find(editorContainer) : null;

    const titleStored = window.localStorage.getItem(titleStoreId);
    const bodyStored = editor ? window.localStorage.getItem(bodyEditorStoreId) : window.localStorage.getItem(bodyStoreId);

    const save = () => {
      const titleVal = $title.val();
      const bodyVal = editor ? JSON.stringify(editor.getContents()) : $body.val();

      if (titleVal.length > 0) {
        window.localStorage.setItem(titleStoreId, titleVal);
      }

      if(bodyVal.length > 0) {
        editor ? window.localStorage.setItem(bodyEditorStoreId, bodyVal) : window.localStorage.setItem(bodyStoreId, bodyVal);
      }
    }

    if(titleStored) {
      $title.val(titleStored);
    } else {
      save();
    }

    if(bodyStored) {
      editor ? editor.setContents(JSON.parse(bodyStored)) : $body.val(bodyStored);
    } else {
      save();
    }

    $title.on("change", () => {
      save();
    });

    if (editor) {
      editor.on(Quill.events.TEXT_CHANGE, (delta, source) => {
        save();
      });
    }  else {
      $body.on("change", () => {
        save();
      });
    }

    $form.on("formvalid.zf.abide", function() {
      window.localStorage.removeItem(titleStoreId);
      editor ? window.localStorage.removeItem(bodyEditorStoreId) : window.localStorage.removeItem(bodyStoreId);
    });
  }
});
