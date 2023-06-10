<template>
  <div
    :data-index="index"
    :data-offset="offsetPosition"
    class="absolute w-full h-full overflow-auto rounded-sm shadow ring-1 ring-black ring-opacity-10 bg-theme-current-screen"
    :style="{
      zIndex: index,
      top: offsetPosition,
      left: offsetPosition,
      opacity: offsetOpacity,
    }"
  >
    <component v-show="isVisible" :is="component" />

    <div
      v-show="!isVisible"
      class="text-xs p-0.5"
      @click="navigateBackToThisScreen()"
    >
      {{ title }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { Component as VueComponent, computed } from "vue";
import { navigateBackToScreen } from "../models/navigation";

const props = defineProps<{
  title: String;
  component: VueComponent;
  index: number;
  currentIndex: number;
}>();

const OFFSET_POSITION_IN_PIXELS = -20;
const OFFSET_OPACITY_IN_PERCENTAGE = 0.3;

const offsetPosition = computed((): string => {
  const offset = props.currentIndex - props.index;

  return offset * OFFSET_POSITION_IN_PIXELS + "px";
});

const offsetOpacity = computed((): string => {
  const offset = props.currentIndex - props.index;

  return Math.max(
    0,
    1 - Math.abs(offset) * OFFSET_OPACITY_IN_PERCENTAGE
  ).toString();
});

const isVisible = computed((): boolean => {
  return props.index === props.currentIndex;
});

const navigateBackToThisScreen = () => {
  if (props.index === props.currentIndex) {
    return;
  }

  navigateBackToScreen(props.index);
};
</script>
