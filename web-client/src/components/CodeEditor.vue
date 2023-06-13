<template>
  <div ref="element">{{ code }}</div>
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

const emit = defineEmits<{
  (e: "change", value: string): void;
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

    editor.on("change", (_ev) => {
      emit("change", editor.getValue());
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
  }
});
</script>
