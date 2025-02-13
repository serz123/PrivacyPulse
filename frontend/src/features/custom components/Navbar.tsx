import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
} from "@/components/ui/navigation-menu";
import { useLogin } from "../static pages/hooks/useLogin";
import { useLocation } from "react-router-dom";
import { useState } from "react";
import { MenuIcon, X } from "lucide-react";

export default function Navbar() {
  const { handleLogin, handleLogout } = useLogin();
  const location = useLocation();
  const [menuOpen, setMenuOpen] = useState(false);

  const token = localStorage.getItem("token");

  // Helper function to determine if the link is active
  const isActive = (path: string) => location.pathname === path;

  return (
    <NavigationMenu className="relative mb-32 flex justify-end items-center  ">
      <button
        className="text-2xl md:hidden absolute top-4 right-4 z-50"
        onClick={() => setMenuOpen(!menuOpen)}
        aria-label="Toggle Menu"
      >
        {menuOpen ? <X /> : <MenuIcon />}
      </button>

      <NavigationMenuList
        className={`${
          menuOpen
            ? "fixed inset-0 bg-white z-40 flex flex-col justify-center gap-4 text-lg items-center"
            : "hidden"
        } md:flex md:relative md:flex-row md:!space-x-1`}
      >
        {!token && (
          <NavigationMenuItem className="-mr-3 rounded-lg bg-primary text-white py-1 px-2 md:mr-3 lg:mr-3">
            <NavigationMenuLink
              onClick={handleLogin}
              className="cursor-pointer"
            >
              Login
            </NavigationMenuLink>
          </NavigationMenuItem>
        )}

        {token && (
          <NavigationMenuItem className="-mr-3 rounded-lg bg-primary text-white py-1 px-2 md:mr-3 lg:mr-3">
            <NavigationMenuLink
              onClick={handleLogout}
              className="cursor-pointer"
            >
              Logout
            </NavigationMenuLink>
          </NavigationMenuItem>
        )}

        <NavigationMenuItem className="px-2">
          <NavigationMenuLink
            href="/"
            className={`rounded-lg py-1 px-2 ${
              isActive("/") ? "text-primary font-bold" : ""
            }`}
          >
            Home
          </NavigationMenuLink>
        </NavigationMenuItem>

        {token && (
          <NavigationMenuItem className="px-2">
            <NavigationMenuLink
              href="/profile"
              className={`rounded-lg py-1 px-2 ${
                isActive("/profile") ? "text-primary font-bold" : ""
              }`}
            >
              Profile
            </NavigationMenuLink>
          </NavigationMenuItem>
        )}

        <NavigationMenuItem className="px-2">
          <NavigationMenuLink
            href="/terms-conditions"
            className={`rounded-lg py-1 px-2 ${
              isActive("/terms-conditions") ? "text-primary font-bold" : ""
            }`}
          >
            Terms and Conditions
          </NavigationMenuLink>
        </NavigationMenuItem>

        <NavigationMenuItem className="px-2">
          <NavigationMenuLink
            href="/privacy-policy"
            className={`rounded-lg py-1 px-2 ${
              isActive("/privacy-policy") ? "text-primary font-bold" : ""
            }`}
          >
            Privacy Policy
          </NavigationMenuLink>
        </NavigationMenuItem>

        <NavigationMenuItem className="px-2">
          <NavigationMenuLink
            href="/contact"
            className={`rounded-lg py-1 px-2 ${
              isActive("/contact") ? "text-primary font-bold" : ""
            }`}
          >
            Contact
          </NavigationMenuLink>
        </NavigationMenuItem>
      </NavigationMenuList>
    </NavigationMenu>
  );
}
