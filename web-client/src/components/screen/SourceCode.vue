<template>
  <div class="relative h-full">
    <CodeEditor
      v-if="sourceCode"
      class="flex-grow h-full"
      :file-path="sourceCode.file_path"
      :code="sourceCode.code"
      :symbols="sourceCode.symbols"
      @change="onChange"
      @click-symbol="onClickSymbol"
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
import { computed, onUnmounted, ref, watch, h } from "vue";
import { useSourceCode } from "../../models/useSoureCode";
import { registerShortcut } from "../../models/shortcut";
import { Symbol } from "../../models/symbol";
import CodeEditor from "../CodeEditor.vue";
import { pushScreen } from "../../models/navigation";
import SourceCode from "./SourceCode.vue";

const props = defineProps<{
  identifier: string;
}>();

const { sourceCode, write } = useSourceCode(props.identifier);

const unsavedContent = ref<string | null>(null);

const onChange = (value: string) => {
  unsavedContent.value = value;
};

const onClickSymbol = (ev: MouseEvent, symbol: Symbol) => {
  if (
    symbol.kind === "type_inference" &&
    symbol.dependency_identifier !== null
  ) {
    if (ev.ctrlKey) {
      const component = h(SourceCode, {
        identifier: symbol.dependency_identifier,
      });

      pushScreen(`source: ${symbol.dependency_identifier}`, component);
    }
  }

  console.log(symbol);
};

watch(sourceCode, (newSourceCode) => {
  if (newSourceCode !== null) {
    unsavedContent.value = newSourceCode.code;
  }
});

const hasUnsavedChanges = computed((): boolean => {
  return unsavedContent.value != sourceCode.value?.code;
});

onUnmounted(
  registerShortcut("ctrl+s", () => {
    if (typeof unsavedContent.value === "string") {
      write(unsavedContent.value);
    }
  })
);
</script>
