<template>
  <div ref="element" class="h-full">{{ code }}</div>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";
import * as ace from "ace-builds";
import "ace-builds/css/ace.css";

import "ace-builds/src-noconflict/mode-ruby";
import "ace-builds/src-noconflict/theme-github";

defineProps<{
  code: string;
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
  }
});
</script>
