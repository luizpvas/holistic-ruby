<template>
  <div
    :data-index="index"
    :data-offset="offsetPosition"
    class="absolute w-full h-full overflow-auto border border-red-500 bg-white"
    :style="{ zIndex: index, top: offsetPosition, left: offsetPosition }"
  >
    <component v-if="index == currentIndex" :is="component" />
    <div v-else class="text-xs p-0.5">{{ title }}</div>
  </div>
</template>

<script setup lang="ts">
import { Component as VueComponent, computed } from "vue";

const props = defineProps<{
  title: String;
  component: VueComponent;
  index: number;
  currentIndex: number;
}>();

const offsetPosition = computed((): string => {
  const offset = props.currentIndex - props.index;

  return offset * -20 + "px";
});
</script>
