<template>
  <div
    class="absolute top-2 right-2 bg-slate-800 text-white text-xs px-2 py-1 rounded-md divide-x"
  >
    <span title="Current application" class="pr-2">
      {{ currentApplicationName }}
    </span>

    <span title="Amount of applications" class="pl-2">
      {{ applications.length }}
    </span>
  </div>
</template>

<script setup lang="ts">
import { applications, currentApplicationName } from "../models/application";
</script>
