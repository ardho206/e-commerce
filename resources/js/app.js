import { initFlowbite } from "flowbite";
import "./bootstrap";
import "flowbite";

window.addEventListener("livewire:navigated", function () {
    initFlowbite();
});
