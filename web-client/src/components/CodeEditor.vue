<template>
  <div ref="element"></div>
</template>

<style>
.type-inference-symbol {
}
</style>

<script setup lang="ts">
import { onMounted, ref, watch } from "vue";
import * as ace from "ace-builds";
import "ace-builds/css/ace.css";

import "ace-builds/src-noconflict/mode-ruby";
import "ace-builds/src-noconflict/theme-github";
import { Symbol } from "../models/symbol";

const props = defineProps<{
  code: string;
  filePath: string;
  symbols: Symbol[];
}>();

const emit = defineEmits<{
  (e: "change", value: string): void;
}>();

const element = ref<HTMLElement | null>(null);

function setupEditorTheme(editor: ace.Ace.Editor) {
  editor.setTheme("ace/theme/github");
  editor.session.setMode("ace/mode/ruby");

  editor.setOptions({
    fontFamily: "Dejavu Sans Mono",
    fontSize: "12px",
  });
}

function disableAceShortcutsToAvoidConflictWithStandShortcuts(
  editor: ace.Ace.Editor
) {
  editor.keyBinding.removeKeyboardHandler(editor.commands);
}

interface MarkerForSymbol {
  id: number;
  startAnchor: ace.Ace.Anchor;
  endAnchor: ace.Ace.Anchor;
}

const markersForSymbols: MarkerForSymbol[] = [];

function addMarkersForSymbols(editor: ace.Ace.Editor, symbols: Symbol[]) {
  markersForSymbols.forEach((markerForSymbol) => {
    markerForSymbol.startAnchor.detach();
    markerForSymbol.endAnchor.detach();

    editor.getSession().removeMarker(markerForSymbol.id);
  });

  markersForSymbols.length = 0;

  symbols.forEach((symbol) => {
    if (symbol.kind !== "type_inference") {
      return;
    }

    const thisParticularSourceLocation = symbol.source_locations.find(
      (sourceLocation) => sourceLocation.file_path === props.filePath
    );

    if (thisParticularSourceLocation === undefined) {
      return;
    }

    const range = new ace.Range(
      thisParticularSourceLocation.start_line - 1,
      thisParticularSourceLocation.start_column,
      thisParticularSourceLocation.end_line - 1,
      thisParticularSourceLocation.end_column
    );

    // It looks like ace's `.d.ts` is missing some overloading with different signatures.
    // @ts-ignore
    const startAnchor = editor.session.doc.createAnchor(range.start);
    // @ts-ignore
    const endAnchor = editor.session.doc.createAnchor(range.end);
    // @ts-ignore
    range.start = startAnchor;
    // @ts-ignore
    range.end = endAnchor;

    const markerId = editor.session.addMarker(
      range,
      "ace_bracket type-inference-symbol",
      "text"
    );

    markersForSymbols.push({
      id: markerId,
      startAnchor: startAnchor,
      endAnchor: endAnchor,
    });
  });
}

onMounted(() => {
  if (element.value) {
    const editor = ace.edit(element.value);

    setupEditorTheme(editor);

    disableAceShortcutsToAvoidConflictWithStandShortcuts(editor);

    const updateEditorContent = () => {
      editor.getSession().setValue(props.code);
      addMarkersForSymbols(editor, props.symbols);
    };

    watch(props, updateEditorContent);
    updateEditorContent();

    editor.on("change", (_ev) => {
      emit("change", editor.getValue());
    });
  }
});
</script>
