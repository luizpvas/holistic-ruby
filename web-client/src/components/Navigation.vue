<template>
  <div class="h-screen w-screen flex items-center justify-center">
    <div class="w-[960px] h-[500px] bg-yellow-100">
      <div v-for="track in tracks" class="h-full">
        <Track :screens="track.screens" :current-index="track.currentIndex" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Track as NavigationTrack } from "../models/navigation";
import Track from "./Track.vue";

defineProps<{
  tracks: NavigationTrack[];
  index: number;
}>();
</script>
