# 🛡️ SheShield Mesh

> **Safety Beyond Connectivity** — When networks fail, emergency signals survive.

**When internet and mobile networks fail, SheShield Mesh ensures emergency SOS alerts survive, travel, and reach help.**

An offline-first emergency communication system that works when everything else doesn't. Using mesh relay technology and decentralized networks, SheShield Mesh keeps emergency signals alive through network shutdowns, disasters, and remote-area blackouts.

---

## 🚨 The Problem We Solve

Traditional safety apps have a fatal flaw: **they stop working exactly when you need them most.**

| Scenario | Traditional Apps | SheShield Mesh |
|----------|-----------------|----------------|
| **Internet Shutdown** | ❌ Fails | ✅ Works offline |
| **No Cellular Signal** | ❌ No alert sent | ✅ Mesh relays signal |
| **Disaster Zone** | ❌ Help unreachable | ✅ Stores & queues alert |
| **Remote Area** | ❌ Connectivity required | ✅ Relays through nearby users |

Millions remain disconnected when they need help most.

**We changed that.**

---

## ✨ Key Features

### 🆘 Offline SOS
Create emergency alerts without internet or cellular connectivity. Alerts are stored securely on your device.

### 🔗 Mesh Relay Network
Emergency signals relay through nearby devices, extending reach beyond individual connectivity limits.

### 📳 Shake-to-SOS
Activate emergency mode instantly — just shake your phone. Because seconds matter.

### 👥 Trusted Contacts
Automatically notify your chosen contacts once connectivity is restored.

### 🟢 Safe Beacon Mode
Create a proactive safety session before entering risky environments. Let your network know you're safe.

### 🤝 Community Rescue Network
Nearby users become part of your safety net — helping relay alerts through a decentralized, privacy-respecting network.

---

## 🏗️ How It Works

```
┌─────────────────────────────────────────────────────┐
│ 1. User presses SOS or shakes phone                 │
├─────────────────────────────────────────────────────┤
│ 2. Alert encrypted & stored locally on device       │
├─────────────────────────────────────────────────────┤
│ 3. Nearby devices receive & relay alert             │
│    (even without cellular service)                  │
├─────────────────────────────────────────────────────┤
│ 4. One device reconnects to internet               │
├─────────────────────────────────────────────────────┤
│ 5. Alert syncs to responders & trusted contacts    │
└─────────────────────────────────────────────────────┘
```

**The signal that refuses to die.**

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Mobile App** | Flutter |
| **Local Storage** | Hive |
| **Offline Comms** | Nearby Connections API |
| **Backend** | Supabase + PostgreSQL |
| **Notifications** | Firebase Cloud Messaging |
| **Hosting** | Vercel |

### Architecture
- **Offline-First Design**: Connectivity is optional, not required
- **End-to-End Encrypted**: Messages encrypted on device
- **Mesh Relay Layer**: Peer-to-peer emergency signal routing
- **Auto-Sync**: Messages automatically sync once online

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Android SDK or Xcode for iOS
- Supabase account
- Firebase project

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/sheshield-mesh.git
cd sheshield-mesh

# Install dependencies
flutter pub get

# Set up environment variables
cp .env.example .env
# Edit .env with your Supabase and Firebase credentials

# Run on device/emulator
flutter run
```

### Environment Variables
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
FIREBASE_PROJECT_ID=your_firebase_project
GOOGLE_MAPS_API_KEY=your_maps_key
```

---

## 📱 Mobile App Usage

### Activating SOS
1. **Shake Method**: Rapidly shake your phone (configurable sensitivity)
2. **Button Method**: Long-press the emergency button (3 seconds)
3. **Voice Method**: Say "SOS" (if enabled)

### Creating a Safe Beacon
```
Home → Safety → Start Beacon → Set Duration → Share with Network
```

### Emergency Contact Management
```
Settings → Trusted Contacts → Add Contact → Set Priority
```

---

## 💾 Data Storage

### On-Device (Hive)
- Pending alerts
- Trusted contact list
- User preferences
- Offline conversation history

### Cloud (Supabase)
- Alert delivery logs
- User authentication
- Contact verification
- Analytics (anonymized)

**Privacy First**: User data syncs only with explicit consent. Mesh relay never stores personal information.

---

## 🔐 Security & Privacy

- ✅ **End-to-End Encryption**: Messages encrypted before leaving device
- ✅ **No Cloud Dependency**: Functions fully offline
- ✅ **Zero Knowledge**: Servers never see message content
- ✅ **Decentralized Relay**: Relay nodes don't log or store data
- ✅ **Privacy by Design**: No tracking, no analytics on sensitive data

---

## 📊 Hackathon MVP Status

**What We Shipped:**
- ✅ Emergency SOS Generation
- ✅ Offline Alert Storage
- ✅ Mesh Relay Simulation
- ✅ Trusted Contact Management
- ✅ Shake Detection
- ✅ Emergency Delivery Workflow
- ✅ Realistic User Journey

**Next Phase:**
- 🔄 Real mesh network testing (500+ user pilot)
- 🔄 Integration with emergency services APIs
- 🔄 Satellite connectivity fallback
- 🔄 Multi-language support (20+ languages)
- 🔄 Community-powered responder network

---

## 👥 Team

| Role | Responsibility |
|------|-----------------|
| **Product** | Shaping the vision and user journey for critical moments |
| **Development** | Building offline-first mobile systems that don't fail |
| **Design** | Crafting calm, intuitive UI for high-stress situations |
| **Research** | Field studies on connectivity blackouts & emergency needs |

---

## 📈 Impact

### Who We Serve
- 👩 **Women in High-Risk Areas**: Millions with unsafe transit and public spaces
- 🌍 **Disaster Zones**: Communities during earthquakes, floods, conflicts
- 📡 **Remote Areas**: Users in connectivity dead zones
- 🛑 **Shutdown Zones**: People affected by network shutdowns
- ✈️ **Transit Dead Zones**: Travelers in tunnels, mountains, oceans

**Current Need**: Estimated 2+ billion women globally lack reliable emergency communication options.

---

## 🤝 Contributing

We welcome contributions that advance emergency safety.

### Development Setup
```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes, test thoroughly
flutter test

# Push and create pull request
git push origin feature/your-feature
```

### Areas We Need Help
- [ ] Emergency service API integrations
- [ ] Multilingual UI/UX
- [ ] Mesh protocol optimization
- [ ] Field testing & validation
- [ ] Community outreach
- [ ] Accessibility improvements

---

## 📝 License

MIT License — Use freely to build safety systems.

---

## 🌐 Links

- 🔗 **Live Prototype**: [SheShield Mesh](https://secure-mesh-whisper.lovable.app/)
- 📧 **Contact**: hello@sheshield.app
- 🐦 **Twitter**: [@SheshieldMesh](https://twitter.com/sheshieldmesh)
- 📱 **Download**: [iOS](https://apps.apple.com/) | [Android](https://play.google.com/)

---

## 💬 Questions?

- **How does it work without internet?** → Alerts are stored locally and relayed through nearby devices using Bluetooth/WiFi Direct
- **Is my data safe?** → Yes. End-to-end encrypted. We never see message content.
- **What if nobody nearby is online?** → Alerts queue locally and sync automatically when connectivity returns
- **Can I use it in a group?** → Yes. Create a Safe Beacon and invite trusted contacts to your network

---

<div align="center">

### **Because Emergencies Don't Wait for Connectivity.**

**Building a future where safety works everywhere.**

🛡️ **SheShield Mesh** — Safety Beyond Connectivity

</div>
