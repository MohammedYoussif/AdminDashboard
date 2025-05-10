"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Loader2 } from "lucide-react";
import { supabase } from "@/lib/supabase";
import { useEffect } from "react";
import { Database } from "@/lib/database.types";

type Category = Database["public"]["Tables"]["categories"]["Row"];

interface AddCategoryForm {
  name: string;
  image: FileList;
}

interface EditCategoryForm {
  name: string;
  image?: FileList;
}

// Add Category Form Component
function AddCategoryForm({
  onSubmit,
  isSubmitting,
  onCancel,
}: {
  onSubmit: (data: AddCategoryForm) => void;
  isSubmitting: boolean;
  onCancel: () => void;
}) {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<AddCategoryForm>();

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="add-name">Name</Label>
        <Input
          id="add-name"
          {...register("name", { required: "Name is required" })}
          placeholder="e.g., Technology"
        />
        {errors.name && (
          <p className="text-sm text-red-500">{errors.name.message}</p>
        )}
      </div>
      <div className="space-y-2">
        <Label htmlFor="add-image">Category Image</Label>
        <Input
          id="add-image"
          type="file"
          accept="image/*"
          {...register("image", {
            required: "Image is required",
            validate: {
              fileSize: (files) =>
                !files[0] ||
                files[0].size <= 5000000 ||
                "Image must be less than 5MB",
              fileType: (files) =>
                !files[0] ||
                files[0].type.startsWith("image/") ||
                "File must be an image",
            },
          })}
        />
        {errors.image && (
          <p className="text-sm text-red-500">{errors.image.message}</p>
        )}
      </div>
      <div className="flex justify-end gap-2">
        <DialogClose asChild>
          <Button type="button" variant="outline" onClick={onCancel}>
            Cancel
          </Button>
        </DialogClose>
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Adding...
            </>
          ) : (
            "Add Category"
          )}
        </Button>
      </div>
    </form>
  );
}

// Edit Category Form Component
function EditCategoryForm({
  category,
  onSubmit,
  isSubmitting,
  onCancel,
}: {
  category: Category;
  onSubmit: (data: EditCategoryForm) => void;
  isSubmitting: boolean;
  onCancel: () => void;
}) {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<EditCategoryForm>({
    defaultValues: {
      name: category.name,
    },
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="edit-name">Name</Label>
        <Input
          id="edit-name"
          {...register("name", { required: "Name is required" })}
          placeholder="e.g., Technology"
        />
        {errors.name && (
          <p className="text-sm text-red-500">{errors.name.message}</p>
        )}
      </div>
      <div className="space-y-2">
        <Label htmlFor="edit-image">Category Image (Optional)</Label>
        {category.image_url && (
          <div className="mb-2">
            <img
              src={category.image_url}
              alt={category.name}
              className="w-20 h-20 object-cover rounded-lg"
            />
          </div>
        )}
        <Input
          id="edit-image"
          type="file"
          accept="image/*"
          {...register("image", {
            validate: {
              fileSize: (files) =>
                !files?.[0] ||
                files[0].size <= 5000000 ||
                "Image must be less than 5MB",
              fileType: (files) =>
                !files?.[0] ||
                files[0].type.startsWith("image/") ||
                "File must be an image",
            },
          })}
        />
        <p className="text-sm text-gray-500">
          Leave empty to keep the current image
        </p>
        {errors.image && (
          <p className="text-sm text-red-500">{errors.image.message}</p>
        )}
      </div>
      <div className="flex justify-end gap-2">
        <DialogClose asChild>
          <Button type="button" variant="outline" onClick={onCancel}>
            Cancel
          </Button>
        </DialogClose>
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Saving...
            </>
          ) : (
            "Save Changes"
          )}
        </Button>
      </div>
    </form>
  );
}

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(
    null
  );
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    const fetchCategories = async () => {
      const { data, error } = await supabase
        .from("categories")
        .select("*")
        .order("name");

      if (!error && data) {
        setCategories(data);
      }
    };

    fetchCategories();
  }, []);

  const handleAdd = async (data: AddCategoryForm) => {
    setIsSubmitting(true);

    try {
      const file = data.image[0];
      const fileExt = file.name.split(".").pop();
      const fileName = `${Math.random().toString(36).slice(2)}.${fileExt}`;

      // Upload file directly
      const { error: uploadError } = await supabase.storage
        .from("category-images")
        .upload(fileName, file);

      if (uploadError) throw uploadError;

      const {
        data: { publicUrl },
      } = supabase.storage.from("category-images").getPublicUrl(fileName);

      // Create category with image URL
      const { error: categoryError } = await supabase
        .from("categories")
        .insert([{ name: data.name, image_url: publicUrl }]);

      if (categoryError) throw categoryError;

      // Refresh categories list
      const { data: newCategories } = await supabase
        .from("categories")
        .select("*")
        .order("name");

      if (newCategories) {
        setCategories(newCategories);
      }
      setIsAddOpen(false);
    } catch (error) {
      console.error("Error adding category:", error);
    }

    setIsSubmitting(false);
  };

  const handleEdit = async (data: EditCategoryForm) => {
    if (!selectedCategory) return;
    setIsSubmitting(true);

    try {
      const updates: { name: string; image_url?: string } = {
        name: data.name,
      };

      // If a new image was uploaded
      if (data.image?.[0]) {
        const file = data.image[0];
        const fileExt = file.name.split(".").pop();
        const fileName = `${Math.random().toString(36).slice(2)}.${fileExt}`;

        // Delete old image if it exists
        if (selectedCategory.image_url) {
          const oldFileName = selectedCategory.image_url.split("/").pop();
          if (oldFileName) {
            await supabase.storage
              .from("category-images")
              .remove([oldFileName]);
          }
        }

        // Upload new image
        const { error: uploadError } = await supabase.storage
          .from("category-images")
          .upload(fileName, file);

        if (uploadError) throw uploadError;

        const {
          data: { publicUrl },
        } = supabase.storage.from("category-images").getPublicUrl(fileName);

        updates.image_url = publicUrl;
      }

      // Update category
      const { error: categoryError } = await supabase
        .from("categories")
        .update(updates)
        .eq("id", selectedCategory.id);

      if (categoryError) throw categoryError;

      // Refresh categories list
      const { data: newCategories } = await supabase
        .from("categories")
        .select("*")
        .order("name");

      if (newCategories) {
        setCategories(newCategories);
      }

      setIsEditOpen(false);
      setSelectedCategory(null);
    } catch (error) {
      console.error("Error editing category:", error);
    }

    setIsSubmitting(false);
  };

  const handleDelete = async (categoryId: string) => {
    const { error } = await supabase
      .from("categories")
      .delete()
      .eq("id", categoryId);

    if (!error) {
      setCategories(
        categories.filter((category) => category.id !== categoryId)
      );
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Categories</h1>
        <Dialog open={isAddOpen} onOpenChange={setIsAddOpen}>
          <DialogTrigger asChild>
            <Button>Add Category</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Add Category</DialogTitle>
            </DialogHeader>
            <AddCategoryForm
              onSubmit={handleAdd}
              isSubmitting={isSubmitting}
              onCancel={() => setIsAddOpen(false)}
            />
          </DialogContent>
        </Dialog>
      </div>

      <div className="border rounded-lg">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Image</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {categories.map((category) => (
              <TableRow key={category.id}>
                <TableCell>
                  {category.image_url && (
                    <img
                      src={category.image_url}
                      alt={category.name}
                      className="w-10 h-10 object-cover"
                    />
                  )}
                </TableCell>
                <TableCell>{category.name}</TableCell>
                <TableCell>
                  <div className="flex gap-2">
                    <Dialog
                      open={isEditOpen && selectedCategory?.id === category.id}
                      onOpenChange={(open) => {
                        if (!open) {
                          setSelectedCategory(null);
                        }
                        setIsEditOpen(open);
                      }}
                    >
                      <DialogTrigger asChild>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setSelectedCategory(category)}
                        >
                          Edit
                        </Button>
                      </DialogTrigger>
                      <DialogContent>
                        <DialogHeader>
                          <DialogTitle>Edit Category</DialogTitle>
                        </DialogHeader>
                        {selectedCategory && (
                          <EditCategoryForm
                            category={selectedCategory}
                            onSubmit={handleEdit}
                            isSubmitting={isSubmitting}
                            onCancel={() => {
                              setSelectedCategory(null);
                              setIsEditOpen(false);
                            }}
                          />
                        )}
                      </DialogContent>
                    </Dialog>
                    <Dialog>
                      <DialogTrigger asChild>
                        <Button variant="destructive" size="sm">
                          Delete
                        </Button>
                      </DialogTrigger>
                      <DialogContent>
                        <DialogHeader>
                          <DialogTitle>Delete Category</DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                          <p>Are you sure you want to delete this category?</p>
                        </div>
                        <div className="flex justify-end gap-2">
                          <DialogClose asChild>
                            <Button variant="outline">Cancel</Button>
                          </DialogClose>
                          <Button
                            variant="destructive"
                            onClick={() => handleDelete(category.id)}
                          >
                            Delete
                          </Button>
                        </div>
                      </DialogContent>
                    </Dialog>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
