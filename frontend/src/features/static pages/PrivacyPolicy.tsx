import { H1 } from "@/components/typography/h1";
import { H2 } from "@/components/typography/h2";
import { P } from "@/components/typography/p";
import { Small } from "@/components/typography/small";

export default function PrivacyPolicy() {
  return (
    <div>
      <H1 text="Privacy Policy" className="mb-2" />
      <Small
        text="Last Updated: 13/12/2024"
        className="text-muted-foreground ml-1"
      />
      <P text="At Privacy Pulse, your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and protect your personal information when you use the App. By using the App, you consent to the practices described in this policy." />

      <H2 text="1. Information We Collect" className="mt-8 -mb-4 " />
      <P
        text="

When you use the App, we may collect the following information:"
      />
      <ul className="my-6 ml-6 list-disc [&>li]:mt-2">
        <li>
          <P text="Personal Information: Your Google email and name are collected when you log in to the App." />
        </li>

        <li>
          <P text="Public Data: We may collect publicly available data, including social media profiles, phone numbers, and addresses associated with you." />
        </li>
      </ul>

      <H2 text="2. How We Use Your Information" className="mt-8 -mb-4 " />
      <P text="The information we collect is used to:" />

      <ul className="my-6 ml-6 list-disc [&>li]:mt-2">
        <li>
          <P text="Provide you with a summary of publicly available information about yourself." />
        </li>

        <li>
          <P text="Improve the App’s functionality and user experience." />
        </li>
      </ul>

      <P text="We do not sell or share your personal information with third parties." />

      <H2 text="3. Data Security" className="mt-8 -mb-4 " />
      <P text="We are committed to protecting your information. We use reasonable administrative, technical, and physical security measures to safeguard your data from unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is completely secure, and we cannot guarantee absolute security." />

      <H2 text="4. Data Retention" className="mt-8 -mb-4 " />
      <P text="We do not store your personal information or scraped data beyond the duration of your use of the App. Your Google email and name are only used for authentication and data scraping purposes during your active session. Once your session ends, this information is no longer retained." />

      <H2 text="5. User Control and Data Rights" className="mt-8 -mb-4 " />
      <P text="You have the right to:" />
      <ul className="my-6 ml-6 list-disc [&>li]:mt-2">
        <li>
          <P text="Access: View the information the App has collected about you." />
        </li>

        <li>
          <P text="Withdraw Consent: Revoke your consent for the App to access your Google account at any time by adjusting your Google account permissions." />
        </li>
      </ul>

      <H2 text="6. Third-Party Services" className="mt-8 -mb-4 " />
      <P text="The App uses Google authentication to allow you to log in. By using Google authentication, you are subject to Google’s Privacy Policy. We are not responsible for the privacy practices of third-party services." />

      <H2 text="7. Cookies and Tracking Technologies" className="mt-8 -mb-4 " />
      <P text="The App does not use cookies or tracking technologies to monitor user behavior. All data collection is done directly through the Google authentication process and data scraping functionality." />

      <H2 text="8. Changes to This Privacy Policy" className="mt-8 -mb-4 " />
      <P text="We may update this Privacy Policy from time to time to reflect changes in our practices or for other operational, legal, or regulatory reasons. If any changes are made, we will notify you by updating the 'Last Updated' date at the top of this policy. We encourage you to review this Privacy Policy periodically." />

      <H2 text="9. Children's Privacy" className="mt-8 -mb-4 " />
      <P text="The App is not intended for use by individuals under the age of 18. We do not knowingly collect personal information from children. If we become aware that we have inadvertently collected personal information from a child, we will delete it immediately." />

      <H2 text="10. Your Consent" className="mt-8 -mb-4 " />
      <P text="By using the App, you consent to the collection, use, and sharing of your information as described in this Privacy Policy." />

      <H2 text="11. Contact Us" className="mt-8 -mb-4 " />
      <P text="If you have any questions or concerns about this Privacy Policy, please contact us at [email address]. By using the App, you agree to the terms outlined in this Privacy Policy." />
    </div>
  );
}
