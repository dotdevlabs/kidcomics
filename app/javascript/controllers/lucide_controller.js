import { Controller } from "@hotwired/stimulus"
import {
  createIcons,
  Plus,
  Pencil,
  Trash2,
  Camera,
  Upload,
  Image,
  GripVertical,
  Tag,
  ArrowLeft,
  BookOpen,
  Info,
  Sparkles,
  AlertCircle,
  Loader,
  CheckCircle,
  Search,
  Filter,
  Star,
  Heart,
  Grid,
  List,
  SlidersHorizontal,
  Calendar,
  Eye,
  ChevronDown,
  X,
  Share2,
  MoreVertical
} from "lucide"

export default class extends Controller {
  connect() {
    createIcons({
      icons: {
        Plus,
        Pencil,
        Trash2,
        Camera,
        Upload,
        Image,
        GripVertical,
        Tag,
        ArrowLeft,
        BookOpen,
        Info,
        Sparkles,
        AlertCircle,
        Loader,
        CheckCircle,
        Search,
        Filter,
        Star,
        Heart,
        Grid,
        List,
        SlidersHorizontal,
        Calendar,
        Eye,
        ChevronDown,
        X,
        Share2,
        MoreVertical
      }
    })
  }
}
