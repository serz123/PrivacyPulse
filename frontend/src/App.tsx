import { BrowserRouter, Route, Routes } from "react-router-dom";
import HomePage from "./features/static pages/HomePage";
import TermsConditionsPage from "./features/static pages/TermsConditionsPage";
import Navbar from "./features/custom components/Navbar";
import Contact from "./features/static pages/ContactUs";
import PrivacyPolicy from "./features/static pages/PrivacyPolicy";
import Profile from "./features/profile/Profile";
import ProtectedRoute from "./features/static pages/ProtectedRoute";
import NotFoundPage from "./features/static pages/NotFoundPage";
import { Toaster } from "@/components/ui/toaster"

function App() {
  return (
    <BrowserRouter>
      <Navbar />
      <Toaster />
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route
          path="/profile"
          element={
            <ProtectedRoute>
              <Profile />
            </ProtectedRoute>
          }
        />
        <Route path="/login" element={<div>Processing Login...</div>} />
        <Route path="/terms-conditions" element={<TermsConditionsPage />} />
        <Route path="/privacy-policy" element={<PrivacyPolicy />} />
        <Route path="/contact" element={<Contact />} />

        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
