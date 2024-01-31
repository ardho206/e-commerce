<x-app-layout>
    <div class="w-full h-[31rem]">
        <img src="{{ asset('image/banner.png') }}" alt=""
            class="object-fill object-center w-full h-full rounded-lg">
    </div>

    <section class="w-full font-poppins my-20">
        <h2 class="text-3xl font-semibold text-center mb-9">Features</h2>
        <div class="grid grid-cols-2 gap-3">
            <div class="w-full relative">
                <img src="{{ asset('image/273e2351_a9f2_4439_a7fb_0bec75f8.jpg') }}" alt=""
                    class="object-cover object-bottom w-full h-[90%] brightness-[.70]">
                <div class="absolute bottom-52 left-10 text-white font-poppins flex flex-col">
                    <h2 class="font-medium text-xl">Nike Air Max INTRLK
                        Lite</h2>
                    <i class="text-sm font-light">You've got to feel the sensation to be the sensation.</i>
                    <button class="text-start px-3 py-1 mt-2 rounded-full bg-white w-fit text-black">Shop</button>
                </div>
            </div>
            <div class="w-full relative">
                <img src="{{ asset('image/1702575515_fe66f431404f6671a02a9.jpg') }}" alt=""
                    class="object-cover object-bottom w-full h-[90%] brightness-[.70]">
                <div class="absolute bottom-52 left-10 text-white font-poppins flex flex-col">
                    <h2 class="font-medium text-xl">Nike Air Max 95 Sneakers</h2>
                    <i class="text-sm font-light">Celebrate workwear's wide appeal with a new take on the Nike Air Max
                        95.</i>
                    <button class="text-start px-3 py-1 mt-2 rounded-full bg-white w-fit text-black">Shop</button>
                </div>
            </div>
        </div>
    </section>

    <section class="w-full font-poppins my-20">
        <h2 class="text-3xl font-semibold text-center mb-9">New Arrivals</h2>
        <div class="grid grid-cols-4 gap-3">
            <div class="w-full">
                <img src="{{ asset('image/product/dunk-low-retro.png') }}" alt=""
                    class="object-cover object-center bg-white">
                <h2 class="capitalize font-medium font-montserrat text-sm mt-1">Nike Dunk Low Retro</h2>
                <p class="capitalize font-medium text-sm text-gray-400">Men's Shoes</p>
                <p class="capitalize font-semibold text-lg mt-1">IDR 1.499.000</p>
            </div>
            <div class="w-full">
                <img src="{{ asset('image/product/air-max-97.png') }}" alt=""
                    class="object-cover object-center bg-white">
                <h2 class="capitalize font-medium font-montserrat text-sm mt-1">Nike Dunk Low Retro</h2>
                <p class="capitalize font-medium text-sm text-gray-400">Men's Shoes</p>
                <p class="capitalize font-semibold text-lg mt-1">IDR 1.499.000</p>
            </div>
            <div class="w-full">
                <img src="{{ asset('image/product/sb-force-58-skate.png') }}" alt=""
                    class="object-cover object-center bg-white">
                <h2 class="capitalize font-medium font-montserrat text-sm mt-1">Nike Dunk Low Retro</h2>
                <p class="capitalize font-medium text-sm text-gray-400">Men's Shoes</p>
                <p class="capitalize font-semibold text-lg mt-1">IDR 1.499.000</p>
            </div>
            <div class="w-full">
                <img src="{{ asset('image/product/air-max-systm.png') }}" alt=""
                    class="object-cover object-center bg-white">
                <h2 class="capitalize font-medium font-montserrat text-sm mt-1">Nike Dunk Low Retro</h2>
                <p class="capitalize font-medium text-sm text-gray-400">Men's Shoes</p>
                <p class="capitalize font-semibold text-lg mt-1">IDR 1.499.000</p>
            </div>
        </div>
    </section>
</x-app-layout>
