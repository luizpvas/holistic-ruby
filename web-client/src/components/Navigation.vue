<template>
  <div v-for="track in tracks">
    <Track :screens="track.screens" :index="track.currentIndex" />
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
