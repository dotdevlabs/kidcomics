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
  CheckCircle
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
        CheckCircle
      }
    })
  }
}
