<template>
  <CodeEditor v-if="sourceCode" :code="sourceCode.code" />
</template>

<script setup lang="ts">
import { useSourceCode } from "../../models/useSoureCode";
import CodeEditor from "../CodeEditor.vue";

const props = defineProps<{
  identifier: string;
}>();

const { sourceCode } = useSourceCode(props.identifier);
</script>
