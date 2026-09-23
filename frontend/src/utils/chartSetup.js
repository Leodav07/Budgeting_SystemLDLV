import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  ArcElement,
} from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement)

export const CHART_COLORS = [
  '#4f46e5',
  '#059669',
  '#d97706',
  '#0284c7',
  '#dc2626',
  '#7c3aed',
  '#db2777',
  '#0d9488',
  '#ca8a04',
  '#4338ca',
]
