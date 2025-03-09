"use client";

export default function LoginPage() {
  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gray-100">
      <h1 className="text-2xl font-bold mb-4">Connexion</h1>
      <input className="border p-2 mb-2" placeholder="Email" />
      <input className="border p-2 mb-4" type="password" placeholder="Mot de passe" />
      <button className="bg-blue-500 text-white px-4 py-2">Se connecter</button>
    </div>
  );
}
