<template>
  <div ref="element" class="h-full">{{ code }}</div>
</template>

<style>
.type-inference-symbol {
  background: red;
}
</style>

<script setup lang="ts">
import { onMounted, ref } from "vue";
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

const element = ref<HTMLElement | null>(null);

onMounted(() => {
  if (element.value) {
    const editor = ace.edit(element.value);
    editor.setTheme("ace/theme/github");
    editor.session.setMode("ace/mode/ruby");

    editor.setOptions({
      fontFamily: "Dejavu Sans Mono",
      fontSize: "12px",
    });

    props.symbols.forEach((symbol) => {
      if (symbol.kind == "namespace") {
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

      editor.session.addMarker(
        range,
        "ace_bracket type-inference-symbol",
        "text"
      );
    });

    // editor.on("click", (ev) => {
    //   const cursorPosition = editor.getCursorPosition();
    //   const token = editor.session.getTokenAt(
    //     cursorPosition.row,
    //     cursorPosition.column
    //   );

    //   const range = new ace.Range(
    //     cursorPosition.row,
    //     token?.start || 0,
    //     cursorPosition.row,
    //     token.start + token.value.length
    //   );

    //   editor.session.addMarker(range, "ace_bracket red");

    //   console.log(token);
    // });
  }
});
</script>
