<?php

use App\Livewire\Actions\Logout;
use Livewire\Volt\Component;

new class extends Component {
    /**
     * Log the current user out of the application.
     */
    public function logout(Logout $logout): void
    {
        $logout();

        $this->redirect('/', navigate: true);
    }
};

?>

<nav class="py-2 px-5 shadow-md sticky top-0 left-0 right-0 bg-white/50 backdrop-blur-md z-50">
    <div class="flex justify-between items-center mt-1 font-montserrat">
        <a wire:navigate href="/"
            class="font-crimson font-bold text-2xl uppercase tracking-tight bg-left-bottom bg-gradient-to-r from-black to-black bg-[length:0%_3px] bg-no-repeat hover:bg-[length:100%_3px] transition-all duration-500 ease-in-out">svelt</a>
        <ul class="flex space-x-3 text-sm font-medium capitalize text-black">
            <li>
                <a href="#">product</a>
            </li>
            <li>
                <a href="#">collection</a>
            </li>
            <li>
                <a href="#">accecorries</a>
            </li>
            <li>
                <a href="#">promos</a>
            </li>
        </ul>
        <div class="flex justify-end items-center space-x-3 text-black text-xl">
            @if (Route::has('login'))
                @auth
                    <x-dropdown align="right" width="48">
                        <x-slot name="trigger">
                            <button
                                class="inline-flex items-center px-2 py-1.5 text-sm leading-4 font-medium rounded-md text-black bg-transparent focus:outline-none transition ease-in-out duration-150">
                                <div x-data="{{ json_encode(['name' => auth()->user()->name]) }}" x-text="name"
                                    x-on:profile-updated.window="name = $event.detail.name"></div>

                                <div class="ms-1">
                                    <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg"
                                        viewBox="0 0 20 20">
                                        <path fill-rule="evenodd"
                                            d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                                            clip-rule="evenodd" />
                                    </svg>
                                </div>
                            </button>
                        </x-slot>

                        <x-slot name="content">
                            <x-dropdown-link :href="route('profile')" wire:navigate>
                                {{ __('Profile') }}
                            </x-dropdown-link>

                            <!-- Authentication -->
                            <button wire:click="logout" class="w-full text-start">
                                <x-dropdown-link>
                                    {{ __('Log Out') }}
                                </x-dropdown-link>
                            </button>
                        </x-slot>
                    </x-dropdown>
                @else
                    <a wire:navigate href="{{ route('login') }}"><i class="fas fa-user"></i></a>
                @endauth
            @endif
            <a href="#"><i class="fas fa-basket-shopping"></i></a>
        </div>
    </div>
</nav>
