<template>
  <div class="">
    <component :is="component" />
  </div>
</template>

<script setup lang="ts">
import { Component as VueComponent } from "vue";

defineProps<{
  title: String;
  component: VueComponent;
}>();
</script>
