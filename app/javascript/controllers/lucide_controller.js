import { Controller } from "@hotwired/stimulus"
import { createIcons,
  // Existing icons (from admin layout)
  LayoutDashboard,
  Users,
  Home,
  FileText,
  BarChart,
  Shield,
  ArrowLeft,
  LogOut,
  // New icons for editor
  ChevronLeft,
  ChevronRight,
  Save,
  Eye,
  Edit3,
  RefreshCw,
  Image,
  Lock,
  GripVertical,
  Trash2,
  Plus,
  X,
  BookOpen,
  Sparkles,
  // Additional icons for book cards and views
  Info,
  Heart,
  Star,
  Pencil,
  Upload,
  CheckCircle,
  Camera
} from "lucide"

export default class extends Controller {
  connect() {
    createIcons({
      icons: {
        // Existing icons
        LayoutDashboard,
        Users,
        Home,
        FileText,
        BarChart,
        Shield,
        ArrowLeft,
        LogOut,
        // New icons for editor
        ChevronLeft,
        ChevronRight,
        Save,
        Eye,
        Edit3,
        RefreshCw,
        Image,
        Lock,
        GripVertical,
        Trash2,
        Plus,
        X,
        BookOpen,
        Sparkles,
        // Additional icons for book cards and views
        Info,
        Heart,
        Star,
        Pencil,
        Upload,
        CheckCircle,
        Camera
      }
    })
  }
}
