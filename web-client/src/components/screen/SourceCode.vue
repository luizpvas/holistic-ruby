<template>
  <div class="relative h-full">
    <CodeEditor
      v-if="sourceCode"
      class="flex-grow h-full"
      :file-path="sourceCode.file_path"
      :code="sourceCode.code"
      :symbols="sourceCode.symbols"
      @change="onChange"
    />

    <div
      class="absolute top-0 right-0 bg-red-500 shadow"
      v-show="hasUnsavedChanges"
    >
      *
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useSourceCode } from "../../models/useSoureCode";
import CodeEditor from "../CodeEditor.vue";

const props = defineProps<{
  identifier: string;
}>();

const { sourceCode, write } = useSourceCode(props.identifier);

const hasUnsavedChanges = ref(false);

const onChange = (value: string) => {
  hasUnsavedChanges.value = value != sourceCode.value?.code;
};
</script>
