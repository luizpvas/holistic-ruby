<template>
  <CodeEditor
    v-if="sourceCode"
    :file-path="sourceCode.file_path"
    :code="sourceCode.code"
    :symbols="sourceCode.symbols"
  />
</template>

<script setup lang="ts">
import { useSourceCode } from "../../models/useSoureCode";
import CodeEditor from "../CodeEditor.vue";

const props = defineProps<{
  identifier: string;
}>();

const { sourceCode } = useSourceCode(props.identifier);
</script>
