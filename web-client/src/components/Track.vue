<template>
  <div class="relative h-full">
    <div v-for="(screen, index) in screens" class="h-full">
      <Screen
        :title="screen.title"
        :index="index"
        :current-index="currentIndex"
        :component="screen.component"
      />
    </div>
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
