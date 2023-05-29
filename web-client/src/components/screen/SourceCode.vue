<template>
  <div>Source Code</div>

  <div>{{ identifier }}</div>
</template>

<script setup lang="ts">
defineProps<{
  identifier: string;
}>();
</script>
