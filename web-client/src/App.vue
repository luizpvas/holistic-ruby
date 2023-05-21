<script setup lang="ts">
import { createApp } from 'vue';
import Loading from './components/screen/Loading.vue';
import { tracks, pushTrack } from './models/navigation';

pushTrack('Loading', createApp(Loading));
</script>

<template>
  <div>
    <div v-for="track in tracks">
      <div v-for="screen in track.screens">
        <div>{{ screen.title }}</div>
      </div>
    </div>
  </div>
</template>
