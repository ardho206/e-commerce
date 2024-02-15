<?php

use function Livewire\Volt\{state};
use Livewire\Attributes\Layout;
use Livewire\Volt\Component;

new #[Layout('layouts.dashboard')] class extends Component {};

?>

<div>
    <form action="">
        <x-input-label for="name" :value="__('Name')" />
        <x-text-input id="name" name="name" type="text" class="mt-1 block w-full" required autofocus
            autocomplete="name" />
    </form>
</div>
