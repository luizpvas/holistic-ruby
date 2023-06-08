<template>
  <div class="relative h-full">
    <Screen
      v-for="(screen, index) in screens"
      :title="screen.title"
      :index="index"
      :current-index="currentIndex"
      :component="screen.component"
    />
  </div>
</template>

<script setup lang="ts">
import { Screen as NavigationScreen } from "../models/navigation";
import Screen from "./Screen.vue";

defineProps<{
  screens: NavigationScreen[];
  currentIndex: number;
}>();
</script>
