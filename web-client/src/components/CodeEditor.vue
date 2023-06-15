<template>
  <div :class="{ 'ctrl-pressed': isCtrlPressed }">
    <div ref="element" class="h-full"></div>
  </div>
</template>

<style>
.type-inference-symbol {
  display: none;
  position: absolute;
  margin: -1px 0 0 -1px;
  z-index: 6;
}

.type-inference-symbol--with-conclusion {
  @apply border border-indigo-400 pointer-events-auto cursor-pointer;
  @apply hover:border-indigo-700 hover:bg-indigo-50;
}

.type-inference-symbol--without-conclusion {
  @apply border border-gray-300;
}

.ctrl-pressed .type-inference-symbol {
  display: block;
}
</style>

<script setup lang="ts">
import { onMounted, ref, watch } from "vue";
import { useCtrlPressed } from "../models/shortcut";

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
  (e: "click-symbol", event: MouseEvent, symbol: Symbol): void;
}>();

const element = ref<HTMLElement | null>(null);

const { isCtrlPressed } = useCtrlPressed();

function setupEditorTheme(editor: ace.Ace.Editor) {
  editor.setTheme("ace/theme/github");
  editor.session.setMode("ace/mode/ruby");

  editor.setOptions({
    fontFamily: "Dejavu Sans Mono",
    fontSize: "12px",
  });
}

function disableAceShortcutsConflictingWithStandShortcuts(
  editor: ace.Ace.Editor
) {
  editor.commands.removeCommand("jumptomatching");
}

interface MarkerForSymbol {
  id: number;
  symbol: Symbol;
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

    const conclusionClass = symbol.dependency_identifier
      ? "type-inference-symbol--with-conclusion"
      : "type-inference-symbol--without-conclusion";

    const markerId = editor.session.addMarker(
      range,
      `type-inference-symbol ${conclusionClass}`,
      "text"
    );

    markersForSymbols.push({
      id: markerId,
      symbol: symbol,
      startAnchor: startAnchor,
      endAnchor: endAnchor,
    });
  });
}

function findSymbolByPosition(row: number, column: number): Symbol | undefined {
  return markersForSymbols.find((markerForSymbol) => {
    const start = markerForSymbol.startAnchor.getPosition();
    const end = markerForSymbol.endAnchor.getPosition();

    return (
      row >= start.row &&
      row <= end.row &&
      column >= start.column &&
      column <= end.column
    );
  })?.symbol;
}

onMounted(() => {
  if (element.value) {
    const editor = ace.edit(element.value);

    setupEditorTheme(editor);

    disableAceShortcutsConflictingWithStandShortcuts(editor);

    const updateEditorContent = () => {
      editor.getSession().setValue(props.code);
      addMarkersForSymbols(editor, props.symbols);
    };

    watch(props, updateEditorContent);
    updateEditorContent();

    editor.on("change", (_ev) => {
      emit("change", editor.getValue());
    });

    editor.on("click", (ev) => {
      const symbol = findSymbolByPosition(
        ev.getDocumentPosition().row,
        ev.getDocumentPosition().column
      );

      if (symbol !== undefined) {
        emit("click-symbol", ev.domEvent, symbol);
      }
    });
  }
});
</script>
