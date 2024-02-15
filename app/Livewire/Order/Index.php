<?php

namespace App\Livewire\Order;

use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.dashboard')]
class Index extends Component
{
    public function render()
    {
        return view('livewire.order.index');
    }
}
