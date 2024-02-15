<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Laravel') }}</title>

    <!-- Web Logo -->
    <link rel="website icon" href="{{ asset('image/logo.png') }}" type="png">

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&family=Poppins:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet">

    <!-- Scripts -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body class="antialiased font-poppins bg-gray-100 flex">
    <div class="grid min-h-screen w-full overflow-hidden lg:grid-cols-[280px_1fr]">
        <div class="hidden border-r bg-white-200 lg:block">
            <div class="flex flex-col gap-2">
                <div class="flex h-[60px] items-center px-6 font-montserrat">
                    <a class="text-2xl font-semibold" href="{{ route('dashboard') }}">Dashboard</a>
                </div>
                <div class="flex-1">
                    <livewire:layout.sidebar />
                </div>
            </div>
        </div>
        <div class="flex flex-col">
            <header class="flex h-14 lg:h-[60px] items-center gap-4 border-b bg-white-200 px-6 dark:bg-gray-800/40">
                <div class="flex-1">
                    @if (request()->routeIs('dashboard'))
                        <h1 class="font-semibold text-lg">Analytics</h1>
                    @elseif (request()->routeIs('orders'))
                        <h1 class="font-semibold text-lg">Recent Orders</h1>
                    @elseif (request()->routeIs('product'))
                        <h1 class="font-semibold text-lg">All Products</h1>
                    @elseif (request()->routeIs('customers'))
                        <h1 class="font-semibold text-lg">Customers</h1>
                    @endif
                </div>
                <div class="flex flex-1 items-center gap-4 md:ml-auto md:gap-2 lg:gap-4">
                    <form class="ml-auto flex-1 sm:flex-initial">
                        <div class="relative">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round"
                                class="absolute left-2.5 top-2.5 h-4 w-4 text-gray-500 dark:text-gray-400">
                                <circle cx="11" cy="11" r="8"></circle>
                                <path d="m21 21-4.3-4.3"></path>
                            </svg>
                            <input
                                class="flex h-10 w-full rounded-md border border-input px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 pl-8 sm:w-[300px] md:w-[200px] lg:w-[300px] bg-white"
                                placeholder="Search orders..." type="search">
                        </div>
                    </form>
                </div>
            </header>
            <main class="flex flex-1 flex-col gap-4 p-4 md:gap-8 md:p-4">
                <div class="relative w-full overflow-auto p-1">
                    {{ $slot }}
                </div>
            </main>
        </div>
    </div>

    <script src="https://kit.fontawesome.com/9bc2b1b0f3.js" crossorigin="anonymous"></script>
</body>

</html>
