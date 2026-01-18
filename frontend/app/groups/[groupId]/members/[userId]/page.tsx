import MemberProfileClient from "./member-profile-client";

export const dynamicParams = false;

export function generateStaticParams() {
  return [{ groupId: "demo", userId: "demo-user" }];
}

export default function MemberProfilePage() {
  return <MemberProfileClient />;
}

