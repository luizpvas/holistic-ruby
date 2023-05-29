<template>
  <div class="p-2">
    <pre class="text-sm">{{ sourceCode?.code }}</pre>
  </div>
</template>

<script setup lang="ts">
import { useSourceCode } from "../../models/useSoureCode";

const props = defineProps<{
  identifier: string;
}>();

const { sourceCode } = useSourceCode(props.identifier);
</script>
