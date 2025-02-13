import { H1 } from "@/components/typography/h1";
import { ReactNode } from "react";

export default function ProtectedRoute({ children }: { children: ReactNode }) {
  const token = localStorage.getItem("token");

  if (!token) {
    return (
    <div className="flex flex-col items-center justify-center ">
        <H1 text="404 - Page Not Found" className="!text-9xl font-bold text-primary mb-10" />
        <p>Sorry, the page you are looking for does not exist. Go back to the <a href="/" className="font-bold">homepage</a>.</p>
    </div>
    )
  }

  return <>{children}</>;

}