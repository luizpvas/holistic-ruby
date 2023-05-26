<template>
  <div v-for="screen in screens">
    <Screen :title="screen.title" :component="screen.component" />
  </div>
</template>

<script setup lang="ts">
import { Screen as NavigationScreen } from "../models/navigation";
import Screen from "./Screen.vue";

defineProps<{
  screens: NavigationScreen[];
  index: number;
}>();
</script>
